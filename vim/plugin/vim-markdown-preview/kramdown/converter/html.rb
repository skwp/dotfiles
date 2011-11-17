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

    # Converts a Kramdown::Document to HTML.
    class Html < Base

      include ::Kramdown::Utils::HTML

      # DEPRECATED: use #html_attributes
      def options_for_element(el)
        warn("DEPRECATION WARNING: this method will be deprecated in the next release, use #html_attributes instead")
        html_attributes(el)
      end

      # :stopdoc:

      # Defines the amount of indentation used when nesting HTML tags.
      INDENTATION = 2

      begin
        require 'coderay'

        # Highlighting via coderay is available if this constant is +true+.
        HIGHLIGHTING_AVAILABLE = true
      rescue LoadError => e
        HIGHLIGHTING_AVAILABLE = false
      end

      # Initialize the HTML converter with the given Kramdown document +doc+.
      def initialize(doc)
        super
        @footnote_counter = @footnote_start = @doc.options[:footnote_nr]
        @footnotes = []
        @toc = []
        @toc_code = nil
      end

      def convert(el, indent = -INDENTATION, opts = {})
        send("convert_#{el.type}", el, indent, opts)
      end

      def inner(el, indent, opts)
        result = ''
        indent += INDENTATION
        el.children.each do |inner_el|
          result << send("convert_#{inner_el.type}", inner_el, indent, opts)
        end
        result
      end

      def convert_blank(el, indent, opts)
        "\n"
      end

      def convert_text(el, indent, opts)
        escape_html(el.value, :text)
      end

      def convert_p(el, indent, opts)
        if el.options[:transparent]
          "#{inner(el, indent, opts)}"
        else
          "#{' '*indent}<p#{html_attributes(el)}>#{inner(el, indent, opts)}</p>\n"
        end
      end

      def convert_codeblock(el, indent, opts)
        if el.options[:attr] && el.options[:attr]['lang'] && HIGHLIGHTING_AVAILABLE
          el = Marshal.load(Marshal.dump(el)) # so that the original is not changed
          opts = {:wrap => @doc.options[:coderay_wrap], :line_numbers => @doc.options[:coderay_line_numbers],
            :line_number_start => @doc.options[:coderay_line_number_start], :tab_width => @doc.options[:coderay_tab_width],
            :bold_every => @doc.options[:coderay_bold_every], :css => @doc.options[:coderay_css]}
          result = CodeRay.scan(el.value, el.options[:attr].delete('lang').to_sym).html(opts).chomp + "\n"
          "#{' '*indent}<div#{html_attributes(el)}>#{result}#{' '*indent}</div>\n"
        else
          result = escape_html(el.value)
          if el.options[:attr] && el.options[:attr].has_key?('class') && el.options[:attr]['class'] =~ /\bshow-whitespaces\b/
            result.gsub!(/(?:(^[ \t]+)|([ \t]+$)|([ \t]+))/) do |m|
              suffix = ($1 ? '-l' : ($2 ? '-r' : ''))
              m.scan(/./).map do |c|
                case c
                when "\t" then "<span class=\"ws-tab#{suffix}\">\t</span>"
                when " " then "<span class=\"ws-space#{suffix}\">&#8901;</span>"
                end
              end.join('')
            end
          end
          "#{' '*indent}<pre#{html_attributes(el)}><code>#{result}#{result =~ /\n\Z/ ? '' : "\n"}</code></pre>\n"
        end
      end

      def convert_blockquote(el, indent, opts)
        "#{' '*indent}<blockquote#{html_attributes(el)}>\n#{inner(el, indent, opts)}#{' '*indent}</blockquote>\n"
      end

      def convert_header(el, indent, opts)
        el = Marshal.load(Marshal.dump(el)) # so that the original is not changed
        if @doc.options[:auto_ids] && !(el.options[:attr] && el.options[:attr]['id'])
          (el.options[:attr] ||= {})['id'] = generate_id(el.options[:raw_text])
        end
        @toc << [el.options[:level], el.options[:attr]['id'], el.children] if el.options[:attr] && el.options[:attr]['id'] && within_toc_depth?(el)
        "#{' '*indent}<h#{el.options[:level]}#{html_attributes(el)}>#{inner(el, indent, opts)}</h#{el.options[:level]}>\n"
      end

      def within_toc_depth?(el)
        @doc.options[:toc_depth] <= 0 || el.options[:level] <= @doc.options[:toc_depth]
      end

      def convert_hr(el, indent, opts)
        "#{' '*indent}<hr />\n"
      end

      def convert_ul(el, indent, opts)
        if !@toc_code && (el.options[:ial][:refs].include?('toc') rescue nil) && (el.type == :ul || el.type == :ol)
          @toc_code = [el.type, el.options[:attr], (0..128).to_a.map{|a| rand(36).to_s(36)}.join]
          @toc_code.last
        else
          "#{' '*indent}<#{el.type}#{html_attributes(el)}>\n#{inner(el, indent, opts)}#{' '*indent}</#{el.type}>\n"
        end
      end
      alias :convert_ol :convert_ul
      alias :convert_dl :convert_ul

      def convert_li(el, indent, opts)
        output = ' '*indent << "<#{el.type}" << html_attributes(el) << ">"
        res = inner(el, indent, opts)
        if el.children.empty? || (el.children.first.type == :p && el.children.first.options[:transparent])
          output << res << (res =~ /\n\Z/ ? ' '*indent : '')
        else
          output << "\n" << res << ' '*indent
        end
        output << "</#{el.type}>\n"
      end
      alias :convert_dd :convert_li

      def convert_dt(el, indent, opts)
        "#{' '*indent}<dt#{html_attributes(el)}>#{inner(el, indent, opts)}</dt>\n"
      end

      HTML_TAGS_WITH_BODY=['div', 'script']

      def convert_html_element(el, indent, opts)
        res = inner(el, indent, opts)
        if el.options[:category] == :span
          "<#{el.value}#{html_attributes(el)}" << (!res.empty? ? ">#{res}</#{el.value}>" : " />")
        else
          output = ''
          output << ' '*indent if !el.options[:parent_is_raw]
          output << "<#{el.value}#{html_attributes(el)}"
          if !res.empty? && el.options[:parse_type] != :block
            output << ">#{res}</#{el.value}>"
          elsif !res.empty?
            output << ">\n#{res}"  << ' '*indent << "</#{el.value}>"
          elsif HTML_TAGS_WITH_BODY.include?(el.value)
            output << "></#{el.value}>"
          else
            output << " />"
          end
          output << "\n" if el.options[:outer_element] || !el.options[:parent_is_raw]
          output
        end
      end

      def convert_xml_comment(el, indent, opts)
        if el.options[:category] == :block && !el.options[:parent_is_raw]
          ' '*indent + el.value + "\n"
        else
          el.value
        end
      end
      alias :convert_xml_pi :convert_xml_comment
      alias :convert_html_doctype :convert_xml_comment

      def convert_table(el, indent, opts)
        if el.options[:alignment].all? {|a| a == :default}
          alignment = ''
        else
          alignment = el.options[:alignment].map do |a|
            "#{' '*(indent + INDENTATION)}" + (a == :default ? "<col />" : "<col align=\"#{a}\" />") + "\n"
          end.join('')
        end
        "#{' '*indent}<table#{html_attributes(el)}>\n#{alignment}#{inner(el, indent, opts)}#{' '*indent}</table>\n"
      end

      def convert_thead(el, indent, opts)
        "#{' '*indent}<#{el.type}#{html_attributes(el)}>\n#{inner(el, indent, opts)}#{' '*indent}</#{el.type}>\n"
      end
      alias :convert_tbody :convert_thead
      alias :convert_tfoot :convert_thead
      alias :convert_tr  :convert_thead

      def convert_td(el, indent, opts)
        res = inner(el, indent, opts)
        "#{' '*indent}<#{el.type}#{html_attributes(el)}>#{res.empty? ? "&nbsp;" : res}</#{el.type}>\n"
      end
      alias :convert_th :convert_td

      def convert_comment(el, indent, opts)
        if el.options[:category] == :block
          "#{' '*indent}<!-- #{el.value} -->\n"
        else
          "<!-- #{el.value} -->"
        end
      end

      def convert_br(el, indent, opts)
        "<br />"
      end

      def convert_a(el, indent, opts)
        do_obfuscation = el.options[:attr]['href'] =~ /^mailto:/
        if do_obfuscation
          el = Marshal.load(Marshal.dump(el)) # so that the original is not changed
          href = obfuscate(el.options[:attr]['href'].sub(/^mailto:/, ''))
          mailto = obfuscate('mailto')
          el.options[:attr]['href'] = "#{mailto}:#{href}"
        end
        res = inner(el, indent, opts)
        res = obfuscate(res) if do_obfuscation
        "<a#{html_attributes(el)}>#{res}</a>"
      end

      def convert_img(el, indent, opts)
        "<img#{html_attributes(el)} />"
      end

      def convert_codespan(el, indent, opts)
        "<code#{html_attributes(el)}>#{escape_html(el.value)}</code>"
      end

      def convert_footnote(el, indent, opts)
        number = @footnote_counter
        @footnote_counter += 1
        @footnotes << [el.options[:name], @doc.parse_infos[:footnotes][el.options[:name]]]
        "<sup id=\"fnref:#{el.options[:name]}\"><a href=\"#fn:#{el.options[:name]}\" rel=\"footnote\">#{number}</a></sup>"
      end

      def convert_raw(el, indent, opts)
        el.value + (el.options[:category] == :block ? "\n" : '')
      end

      def convert_em(el, indent, opts)
        "<#{el.type}#{html_attributes(el)}>#{inner(el, indent, opts)}</#{el.type}>"
      end
      alias :convert_strong :convert_em

      def convert_entity(el, indent, opts)
        entity_to_str(el.value)
      end

      TYPOGRAPHIC_SYMS = {
        :mdash => [::Kramdown::Utils::Entities.entity('mdash')],
        :ndash => [::Kramdown::Utils::Entities.entity('ndash')],
        :hellip => [::Kramdown::Utils::Entities.entity('hellip')],
        :laquo_space => [::Kramdown::Utils::Entities.entity('laquo'), ::Kramdown::Utils::Entities.entity('nbsp')],
        :raquo_space => [::Kramdown::Utils::Entities.entity('nbsp'), ::Kramdown::Utils::Entities.entity('raquo')],
        :laquo => [::Kramdown::Utils::Entities.entity('laquo')],
        :raquo => [::Kramdown::Utils::Entities.entity('raquo')]
      }
      def convert_typographic_sym(el, indent, opts)
        TYPOGRAPHIC_SYMS[el.value].map {|e| entity_to_str(e)}.join('')
      end

      def convert_smart_quote(el, indent, opts)
        entity_to_str(::Kramdown::Utils::Entities.entity(el.value.to_s))
      end

      def convert_math(el, indent, opts)
        el = Marshal.load(Marshal.dump(el)) # so that the original is not changed
        el.options[:attr] ||= {}
        el.options[:attr]['class'] ||= ''
        el.options[:attr]['class'] += (el.options[:attr]['class'].empty? ? '' : ' ') + 'math'
        type = 'span'
        type = 'div' if el.options[:category] == :block
        "<#{type}#{html_attributes(el)}>#{escape_html(el.value)}</#{type}>#{type == 'div' ? "\n" : ''}"
      end

      def convert_abbreviation(el, indent, opts)
        title = @doc.parse_infos[:abbrev_defs][el.value]
        title = nil if title.empty?
        "<abbr#{title ? " title=\"#{title}\"" : ''}>#{el.value}</abbr>"
      end

      def convert_root(el, indent, opts)
        result = inner(el, indent, opts)
        result << footnote_content
        if @toc_code
          toc_tree = generate_toc_tree(@toc, @toc_code[0], @toc_code[1] || {})
          text = if toc_tree.children.size > 0
                   convert(toc_tree, 0)
                 else
                   ''
                 end
          result.sub!(/#{@toc_code.last}/, text)
        end
        result
      end

      def generate_toc_tree(toc, type, attr)
        sections = Element.new(type, nil, {:attr => {'id' => 'markdown-toc'}.merge(attr)})
        stack = []
        toc.each do |level, id, children|
          li = Element.new(:li, nil, {:level => level})
          li.children << Element.new(:p, nil, {:transparent => true})
          a = Element.new(:a, nil, {:attr => {:href => "##{id}"}})
          a.children += children
          li.children.last.children << a
          li.children << Element.new(type)

          success = false
          while !success
            if stack.empty?
              sections.children << li
              stack << li
              success = true
            elsif stack.last.options[:level] < li.options[:level]
              stack.last.children.last.children << li
              stack << li
              success = true
            else
              item = stack.pop
              item.children.pop unless item.children.last.children.size > 0
            end
          end
        end
        while !stack.empty?
          item = stack.pop
          item.children.pop unless item.children.last.children.size > 0
        end
        sections
      end

      # Helper method for obfuscating the +text+ by using HTML entities.
      def obfuscate(text)
        result = ""
        text.each_byte do |b|
          result += (b > 128 ? b.chr : "&#%03d;" % b)
        end
        result.force_encoding(text.encoding) if RUBY_VERSION >= '1.9'
        result
      end

      # Return a HTML list with the footnote content for the used footnotes.
      def footnote_content
        ol = Element.new(:ol)
        ol.options[:attr] = {'start' => @footnote_start} if @footnote_start != 1
        @footnotes.each do |name, data|
          li = Element.new(:li, nil, {:attr => {:id => "fn:#{name}"}, :first_is_block => true})
          li.children = Marshal.load(Marshal.dump(data[:content].children)) #TODO: probably remove this!!!!
          ol.children << li

          ref = Element.new(:raw, "<a href=\"#fnref:#{name}\" rev=\"footnote\">&#8617;</a>")
          if li.children.last.type == :p
            para = li.children.last
          else
            li.children << (para = Element.new(:p))
          end
          para.children << ref
        end
        (ol.children.empty? ? '' : "<div class=\"footnotes\">\n#{convert(ol, 2)}</div>\n")
      end

    end

  end
end
