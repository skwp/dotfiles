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

require 'rexml/parsers/baseparser'

module Kramdown

  module Converter

    # Converts a Kramdown::Document to the kramdown format.
    class Kramdown < Base

      # :stopdoc:

      include ::Kramdown::Utils::HTML

      def initialize(doc)
        super
        @linkrefs = []
        @footnotes = []
        @abbrevs = []
        @stack = []
      end

      def convert(el, opts = {})
        res = send("convert_#{el.type}", el, opts)
        if el.type != :html_element && el.type != :li && el.type != :dd && (ial = ial_for_element(el))
          res << ial
          res << "\n\n" if el.options[:category] == :block
        end
        res
      end

      def inner(el, opts = {})
        @stack.push([el, opts])
        result = ''
        el.children.each_with_index do |inner_el, index|
          options = opts.dup
          #p [index, inner_el]
          options[:index] = index
          options[:prev] = (index == 0 ? nil : el.children[index-1])
          options[:next] = (index == el.children.length - 1 ? nil : el.children[index+1])
          result << convert(inner_el, options)
        end
        @stack.pop
        result
      end

      def convert_blank(el, opts)
        "\n"
      end

      ESCAPED_CHAR_RE = /(\$\$|[\\*_`\[\]\{\}"'])|^[ ]{0,3}(:)/

      def convert_text(el, opts)
        if opts[:raw_text]
          el.value
        else
          nl = (el.value =~ /\n$/)
          el.value.gsub(/\s+/, ' ').gsub(ESCAPED_CHAR_RE) { "\\#{$1 || $2}" } + (nl ? "\n" : '')
        end
      end

      def convert_p(el, opts)
        res = inner(el, opts).strip.gsub(/\A(?:([#|])|(\d+)\.|([+-]\s))/) do
          $1 || $3 ? "\\#{$1 || $3}" : "#{$2}\\."
        end + "\n"
        if opts[:next] && opts[:next].type == :p && !ial_for_element(el)
          res += "\n"
        end
        res
      end

      CODEBLOCK_PREV_EL = [:ul, :ol, :dl, :codeblock]

      def convert_codeblock(el, opts)
        res = ''
        res << "^\n" if opts[:prev] && ((CODEBLOCK_PREV_EL.include?(opts[:prev].type) && !ial_for_element(opts[:prev])) ||
                                        (opts[:prev].type == :blank &&
                                         opts[:index]-2 >= 0 &&
                                         (tmp = @stack.last.first.children[opts[:index]-2]) &&
                                         CODEBLOCK_PREV_EL.include?(tmp.type) && !ial_for_element(tmp)))
        res << el.value.split(/\n/).map {|l| l.empty? ? "    " : "    #{l}"}.join("\n") + "\n"
      end

      def convert_blockquote(el, opts)
        res = ''
        res << "\n" if opts[:prev] && opts[:prev].type == :blockquote
        res << inner(el, opts).chomp.split(/\n/).map {|l| "> #{l}"}.join("\n") << "\n"
      end

      def convert_header(el, opts)
        res = ''
        res << "\n" if opts[:prev] && opts[:prev].type != :blank
        res << "#{'#' * el.options[:level]} #{inner(el, opts)}"
        res << "   {##{el.options[:attr]['id']}}" if el.options[:attr] && el.options[:attr]['id']
        res << "\n" if opts[:next] && opts[:next].type != :blank
        res << "\n"
      end

      def convert_hr(el, opts)
        "* * *\n"
      end

      def convert_ul(el, opts)
        res = ''
        res << "\n" if opts[:prev] && (opts[:prev].type == :p && !opts[:prev].options[:transparent])
        res << "^\n" if opts[:prev] && ((opts[:prev].type == el.type && !ial_for_element(opts[:prev])) ||
                                        (opts[:prev].type == :blank && opts[:index]-2 >= 0 &&
                                         (tmp = @stack.last.first.children[opts[:index]-2]) &&
                                         tmp.type == el.type && !ial_for_element(tmp)))
        res + inner(el, opts).sub(/\n+\Z/, "\n")
      end
      alias :convert_ol :convert_ul
      alias :convert_dl :convert_ul

      def convert_li(el, opts)
        sym, width = if @stack.last.first.type == :ul
                       ['* ', el.children.first.type == :codeblock ? 4 : 2]
                     else
                       ["#{opts[:index] + 1}.".ljust(4), 4]
                     end
        if ial = ial_for_element(el)
          sym += ial + " "
        end

        first, *last = inner(el, opts).chomp.split(/\n/)
        last = last.map {|l| " "*width + l}.join("\n")
        last = last.empty? ? "\n" : "\n#{last}\n"
        if el.children.first.type == :p && !el.children.first.options[:transparent]
          res = "#{sym}#{first}\n#{last}"
          res << "^\n" if el.children.size == 1 && @stack.last.first.children.last == el &&
            (@stack.last.first.children.any? {|c| c.children.first.type != :p} || @stack.last.first.children.size == 1)
          res
        elsif el.children.first.type == :codeblock
          "#{sym}\n    #{first}#{last}"
        else
          "#{sym}#{first}#{last}"
        end
      end

      def convert_dd(el, opts)
        sym, width = ": ", (el.children.first.type == :codeblock ? 4 : 2)
        if ial = ial_for_element(el)
          sym += ial + " "
        end

        first, *last = inner(el, opts).chomp.split(/\n/)
        last = last.map {|l| " "*width + l}.join("\n")
        text = first + (last.empty? ? '' : "\n" + last)
        if el.children.first.type == :p && !el.children.first.options[:transparent]
          "\n#{sym}#{text}\n"
        elsif el.children.first.type == :codeblock
          "#{sym}\n    #{text}\n"
        else
          "#{sym}#{text}\n"
        end
      end

      def convert_dt(el, opts)
        res = ''
        res << inner(el, opts) << "\n"
      end

      HTML_TAGS_WITH_BODY=['div', 'script']

      def convert_html_element(el, opts)
        markdown_attr = el.options[:category] == :block && el.children.any? do |c|
          c.type != :html_element && (c.type != :p || !c.options[:transparent]) && c.options[:category] == :block
        end
        opts[:force_raw_text] = true if %w{script pre code}.include?(el.value)
        opts[:raw_text] = opts[:force_raw_text] || opts[:block_raw_text] || (el.options[:category] != :span && !markdown_attr)
        opts[:block_raw_text] = true if el.options[:category] == :block && opts[:raw_text]
        res = inner(el, opts)
        if el.options[:category] == :span
          "<#{el.value}#{html_attributes(el)}" << (!res.empty? ? ">#{res}</#{el.value}>" : " />")
        else
          output = ''
          output << "<#{el.value}#{html_attributes(el)}"
          output << " markdown=\"1\"" if markdown_attr
          if !res.empty? && el.options[:parse_type] != :block
            output << ">#{res}</#{el.value}>"
          elsif !res.empty?
            output << ">\n#{res}"  <<  "</#{el.value}>"
          elsif HTML_TAGS_WITH_BODY.include?(el.value)
            output << "></#{el.value}>"
          else
            output << " />"
          end
          output << "\n" if el.options[:outer_element] || !el.options[:parent_is_raw]
          output
        end
      end

      def convert_xml_comment(el, opts)
        if el.options[:category] == :block && !el.options[:parent_is_raw]
          el.value + "\n"
        else
          el.value
        end
      end
      alias :convert_xml_pi :convert_xml_comment
      alias :convert_html_doctype :convert_xml_comment

      def convert_table(el, opts)
        opts[:alignment] = el.options[:alignment]
        inner(el, opts)
      end

      def convert_thead(el, opts)
        rows = inner(el, opts)
        if opts[:alignment].all? {|a| a == :default}
          "#{rows}|" + "-"*10 + "\n"
        else
          "#{rows}| " + opts[:alignment].map do |a|
            case a
            when :left then ":-"
            when :right then "-:"
            when :center then ":-:"
            when :default then "-"
            end
          end.join(' ') + "\n"
        end
      end

      def convert_tbody(el, opts)
        res = ''
        res << inner(el, opts)
        res << '|' << '-'*10 << "\n" if opts[:next] && opts[:next].type == :tbody
        res
      end

      def convert_tfoot(el, opts)
        "|" + "="*10 + "\n#{inner(el, opts)}"
      end

      def convert_tr(el, opts)
        "| " + el.children.map {|c| convert(c, opts)}.join(" | ") + " |\n"
      end

      def convert_td(el, opts)
        inner(el, opts).gsub(/\|/, '\\|')
      end
      alias :convert_th :convert_td

      def convert_comment(el, opts)
        if el.options[:category] == :block
          "{::comment}\n#{el.value}\n{:/}\n"
        else
          "{::comment}#{el.value}{:/}"
        end
      end

      def convert_br(el, opts)
        "  \n"
      end

      def convert_a(el, opts)
        if el.options[:attr]['href'].empty?
          "[#{inner(el, opts)}]()"
        else
          @linkrefs << el
          "[#{inner(el, opts)}][#{@linkrefs.size}]"
        end
      end

      def convert_img(el, opts)
        title = (el.options[:attr]['title'] ? ' "' + el.options[:attr]['title'].gsub(/"/, "&quot;") + '"' : '')
        "![#{el.options[:attr]['alt']}](<#{el.options[:attr]['src']}>#{title})"
      end

      def convert_codespan(el, opts)
        delim = (el.value.scan(/`+/).max || '') + '`'
        "#{delim}#{' ' if delim.size > 1}#{el.value}#{' ' if delim.size > 1}#{delim}"
      end

      def convert_footnote(el, opts)
        @footnotes << [el.options[:name], @doc.parse_infos[:footnotes][el.options[:name]]]
        "[^#{el.options[:name]}]"
      end

      def convert_raw(el, opts)
        if @stack.last.first.type == :html_element
          el.value
        elsif el.options[:category] == :block
          "{::nomarkdown}\n#{el.value}\n{:/}\n"
        else
          "{::nomarkdown}#{el.value}{:/}"
        end
      end

      def convert_em(el, opts)
        "*#{inner(el, opts)}*"
      end

      def convert_strong(el, opts)
        "**#{inner(el, opts)}**"
      end

      def convert_entity(el, opts)
        entity_to_str(el.value)
      end

      TYPOGRAPHIC_SYMS = {
        :mdash => '---', :ndash => '--', :hellip => '...',
        :laquo_space => '<< ', :raquo_space => ' >>',
        :laquo => '<<', :raquo => '>>'
      }
      def convert_typographic_sym(el, opts)
        TYPOGRAPHIC_SYMS[el.value]
      end

      def convert_smart_quote(el, opts)
        el.value.to_s =~ /[rl]dquo/ ? "\"" : "'"
      end

      def convert_math(el, opts)
        (@stack.last.first.type == :p && opts[:prev].nil? ? "\\" : '') + "$$#{el.value}$$" + (el.options[:category] == :block ? "\n" : '')
      end

      def convert_abbreviation(el, opts)
        el.value
      end

      def convert_root(el, opts)
        res = inner(el, opts)
        res << create_link_defs
        res << create_footnote_defs
        res << create_abbrev_defs
        res
      end

      def create_link_defs
        res = ''
        res << "\n\n" if @linkrefs.size > 0
        @linkrefs.each_with_index do |el, i|
          link = (el.type == :a ? el.options[:attr]['href'] : el.options[:attr]['src'])
          link = "<#{link}>" if link =~ / /
          title = el.options[:attr]['title']
          res << "[#{i+1}]: #{link} #{title ? '"' + title.gsub(/"/, "&quot;") + '"' : ''}\n"
        end
        res
      end

      def create_footnote_defs
        res = ''
        res = "\n" if @footnotes.size > 0
        @footnotes.each do |name, data|
          res << "\n[^#{name}]:\n"
          res << inner(data[:content]).chomp.split(/\n/).map {|l| "    #{l}"}.join("\n")
        end
        res
      end

      def create_abbrev_defs
        return '' unless @doc.parse_infos[:abbrev_defs]
        res = ''
        @doc.parse_infos[:abbrev_defs].each do |name, text|
          res << "*[#{name}]: #{text}\n"
        end
        res
      end

      # Return the IAL containing the attributes of the element +el+.
      def ial_for_element(el)
        res = (el.options[:attr] || {}).map do |k,v|
          next if [:img, :a].include?(el.type) && ['href', 'src', 'alt', 'title'].include?(k)
          next if el.type == :header && k == 'id'
          v.nil? ? '' : " #{k}=\"#{v.to_s}\""
        end.compact.sort.join('')
        res = "toc" + (res.strip.empty? ? '' : " #{res}") if (el.type == :ul || el.type == :ol) &&
          (el.options[:ial][:refs].include?('toc') rescue nil)
        res.strip.empty? ? nil : "{:#{res}}"
      end

    end

  end
end
