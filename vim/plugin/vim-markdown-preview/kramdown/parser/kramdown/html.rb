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

require 'kramdown/parser/html'

module Kramdown
  module Parser
    class Kramdown

      include Kramdown::Parser::Html::Parser

      def handle_kramdown_html_tag(el, closed)
        parse_type = if @tree.type != :html_element || @tree.options[:parse_type] != :raw
                       (@doc.options[:parse_block_html] ? HTML_PARSE_AS[el.value] : :raw)
                     else
                       :raw
                     end
        if val = html_parse_type(el.options[:attr].delete('markdown'))
          parse_type = (val == :default ? HTML_PARSE_AS[el.value] : val)
        end

        @src.scan(/[ \t]*\n/) if parse_type == :block
        el.options[:outer_element] = true if @tree.type != :html_element
        el.options[:parent_is_raw] = true if @tree.type == :html_element && @tree.options[:parse_type] == :raw
        el.options[:parse_type] = parse_type

        if !closed
          if parse_type == :block
            end_tag_found = parse_blocks(el)
            if !end_tag_found
              warning("Found no end tag for '#{el.value}' - auto-closing it")
            end
          elsif parse_type == :span
            curpos = @src.pos
            if result = @src.scan_until(/(?=<\/#{el.value}\s*>)/m)
              add_text(extract_string(curpos...@src.pos, @src), el)
              @src.scan(HTML_TAG_CLOSE_RE)
            else
              add_text(@src.scan(/.*/m), el)
              warning("Found no end tag for '#{el.value}' - auto-closing it")
            end
          else
            parse_raw_html(el, &method(:handle_kramdown_html_tag))
          end
          @src.scan(/[ \t]*\n/) unless (@tree.type == :html_element && @tree.options[:parse_type] == :raw)
        end
      end

      # Return the HTML parse type defined by the string +val+, i.e. raw when "0", default parsing
      # (return value +nil+) when "1", span parsing when "span" and block parsing when "block". If
      # +val+ is nil, then the default parsing mode is used.
      def html_parse_type(val)
        case val
        when "0" then :raw
        when "1" then :default
        when "span" then :span
        when "block" then :block
        when NilClass then nil
        else
          warning("Invalid markdown attribute val '#{val}', using default")
          nil
        end
      end


      HTML_BLOCK_START = /^#{OPT_SPACE}<(#{REXML::Parsers::BaseParser::UNAME_STR}|\?|!--|\/)/

      # Parse the HTML at the current position as block level HTML.
      def parse_block_html
        if result = @src.scan(HTML_COMMENT_RE)
          @tree.children << Element.new(:xml_comment, result, :category => :block)
          @src.scan(/[ \t]*\n/)
          true
        elsif result = @src.scan(HTML_INSTRUCTION_RE)
          @tree.children << Element.new(:xml_pi, result, :category => :block)
          @src.scan(/[ \t]*\n/)
          true
        else
          if result = @src.check(/^#{OPT_SPACE}#{HTML_TAG_RE}/) && !HTML_SPAN_ELEMENTS.include?(@src[1])
            @src.pos += @src.matched_size
            handle_html_start_tag(&method(:handle_kramdown_html_tag))
            Kramdown::Parser::Html::ElementConverter.new(@doc).process(@tree.children.last) if @doc.options[:html_to_native]
            true
          elsif result = @src.check(/^#{OPT_SPACE}#{HTML_TAG_CLOSE_RE}/) && !HTML_SPAN_ELEMENTS.include?(@src[1])
            @src.pos += @src.matched_size
            name = @src[1]

            if @tree.type == :html_element && @tree.value == name
              throw :stop_block_parsing, :found
            else
              warning("Found invalidly used HTML closing tag for '#{name}' - ignoring it")
              true
            end
          else
            false
          end
        end
      end
      define_parser(:block_html, HTML_BLOCK_START)


      HTML_SPAN_START = /<(#{REXML::Parsers::BaseParser::UNAME_STR}|\?|!--|\/)/

      # Parse the HTML at the current position as span level HTML.
      def parse_span_html
        if result = @src.scan(HTML_COMMENT_RE)
          @tree.children << Element.new(:xml_comment, result, :category => :span)
        elsif result = @src.scan(HTML_INSTRUCTION_RE)
          @tree.children << Element.new(:xml_pi, result, :category => :span)
        elsif result = @src.scan(HTML_TAG_CLOSE_RE)
          warning("Found invalidly used HTML closing tag for '#{@src[1]}' - ignoring it")
        elsif result = @src.scan(HTML_TAG_RE)
          return if HTML_BLOCK_ELEMENTS.include?(@src[1])

          reset_pos = @src.pos
          attrs = {}
          @src[2].scan(HTML_ATTRIBUTE_RE).each {|name,sep,val| attrs[name] = val.gsub(/\n+/, ' ')}

          do_parsing = (HTML_PARSE_AS_RAW.include?(@src[1]) || @tree.options[:parse_type] == :raw ? false : @doc.options[:parse_span_html])
          if val = html_parse_type(attrs.delete('markdown'))
            if val == :block
              warning("Cannot use block level parsing in span level HTML tag - using default mode")
            elsif val == :span
              do_parsing = true
            elsif val == :default
              do_parsing = !HTML_PARSE_AS_RAW.include?(@src[1])
            elsif val == :raw
              do_parsing = false
            end
          end

          el = Element.new(:html_element, @src[1], :attr => attrs, :category => :span, :parse_type => (do_parsing ? :span : :raw))
          @tree.children << el
          stop_re = /<\/#{Regexp.escape(@src[1])}\s*>/
          if !@src[4] && HTML_ELEMENTS_WITHOUT_BODY.include?(el.value)
            warning("The HTML tag '#{el.value}' cannot have any content - auto-closing it")
          elsif !@src[4]
            if parse_spans(el, stop_re, (do_parsing ? nil : [:span_html]))
              @src.scan(stop_re)
            else
              warning("Found no end tag for '#{el.value}' - auto-closing it")
              add_text(@src.scan(/.*/m), el)
            end
          end
          Kramdown::Parser::Html::ElementConverter.new(@doc).process(el) if @doc.options[:html_to_native]
        else
          add_text(@src.scan(/./))
        end
      end
      define_parser(:span_html, HTML_SPAN_START, '<')

    end
  end
end
