# -*- coding: utf-8 -*-
#
#--
# Copyright (C) 2009-2010 Thomas Leitner <t_leitner@gmx.at>
#
# This file is part of kramdown.
#
# kramdown is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
#

module Kramdown
  module Parser
    class Kramdown

      PUNCTUATION_CHARS = "_.:,;!?-"
      LINK_ID_CHARS = /[a-zA-Z0-9 #{PUNCTUATION_CHARS}]/
      LINK_ID_NON_CHARS = /[^a-zA-Z0-9 #{PUNCTUATION_CHARS}]/
      LINK_DEFINITION_START = /^#{OPT_SPACE}\[(#{LINK_ID_CHARS}+)\]:[ \t]*(?:<(.*?)>|([^\s]+))[ \t]*?(?:\n?[ \t]*?(["'])(.+?)\4[ \t]*?)?\n/

      # Parse the link definition at the current location.
      def parse_link_definition
        @src.pos += @src.matched_size
        link_id, link_url, link_title = @src[1].downcase, @src[2] || @src[3], @src[5]
        warning("Duplicate link ID '#{link_id}' - overwriting") if @doc.parse_infos[:link_defs][link_id]
        @doc.parse_infos[:link_defs][link_id] = [link_url, link_title]
        true
      end
      define_parser(:link_definition, LINK_DEFINITION_START)


      # This helper methods adds the approriate attributes to the element +el+ of type +a+ or +img+
      # and the element itself to the <tt>@tree</tt>.
      def add_link(el, href, title, alt_text = nil)
        el.options[:attr] ||= {}
        el.options[:attr]['title'] = title if title
        if el.type == :a
          el.options[:attr]['href'] = href
        else
          el.options[:attr]['src'] = href
          el.options[:attr]['alt'] = alt_text
          el.children.clear
        end
        @tree.children << el
      end

      LINK_TEXT_BRACKET_RE = /\\\[|\\\]|\[|\]/
      LINK_INLINE_ID_RE = /\s*?\[(#{LINK_ID_CHARS}+)?\]/
      LINK_INLINE_TITLE_RE = /\s*?(["'])(.+?)\1\s*?\)/
      LINK_START = /!?\[(?=[^^])/

      # Parse the link at the current scanner position. This method is used to parse normal links as
      # well as image links.
      def parse_link
        result = @src.scan(LINK_START)
        reset_pos = @src.pos

        link_type = (result =~ /^!/ ? :img : :a)

        # no nested links allowed
        if link_type == :a && (@tree.type == :img || @tree.type == :a || @stack.any? {|t,s| t && (t.type == :img || t.type == :a)})
          add_text(result)
          return
        end
        el = Element.new(link_type)

        stop_re = /\]|!?\[/
        count = 1
        found = parse_spans(el, stop_re) do
          case @src.matched
          when "[", "!["
            count += 1
          when "]"
            count -= 1
          end
          count - el.children.select {|c| c.type == :img}.size == 0
        end
        if !found || (link_type == :a && el.children.empty?)
          @src.pos = reset_pos
          add_text(result)
          return
        end
        alt_text = extract_string(reset_pos...@src.pos, @src)
        conv_link_id = alt_text.gsub(/(\s|\n)+/m, ' ').gsub(LINK_ID_NON_CHARS, '').downcase
        @src.scan(stop_re)

        # reference style link or no link url
        if @src.scan(LINK_INLINE_ID_RE) || !@src.check(/\(/)
          link_id = (@src[1] || conv_link_id).downcase
          if link_id.empty?
            @src.pos = reset_pos
            add_text(result)
          elsif @doc.parse_infos[:link_defs].has_key?(link_id)
            add_link(el, @doc.parse_infos[:link_defs][link_id].first, @doc.parse_infos[:link_defs][link_id].last, alt_text)
          else
            warning("No link definition for link ID '#{link_id}' found")
            @src.pos = reset_pos
            add_text(result)
          end
          return
        end

        # link url in parentheses
        if @src.scan(/\(<(.*?)>/)
          link_url = @src[1]
          if @src.scan(/\)/)
            add_link(el, link_url, nil, alt_text)
            return
          end
        else
          link_url = ''
          re = /\(|\)|\s/
          nr_of_brackets = 0
          while temp = @src.scan_until(re)
            link_url += temp
            case @src.matched
            when /\s/
              break
            when '('
              nr_of_brackets += 1
            when ')'
              nr_of_brackets -= 1
              break if nr_of_brackets == 0
            end
          end
          link_url = link_url[1..-2]

          if nr_of_brackets == 0
            add_link(el, link_url, nil, alt_text)
            return
          end
        end

        if @src.scan(LINK_INLINE_TITLE_RE)
          add_link(el, link_url, @src[2], alt_text)
        else
          @src.pos = reset_pos
          add_text(result)
        end
      end
      define_parser(:link, LINK_START, '!?\[')

    end
  end
end
