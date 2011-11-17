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
require 'strscan'

module Kramdown

  module Parser

    # Used for parsing a HTML document.
    class Html < Base

      # Contains all constants that are used when parsing.
      module Constants
        #:stopdoc:
        # The following regexps are based on the ones used by REXML, with some slight modifications.
        HTML_DOCTYPE_RE = /<!DOCTYPE.*?>/m
        HTML_COMMENT_RE = /<!--(.*?)-->/m
        HTML_INSTRUCTION_RE = /<\?(.*?)\?>/m
        HTML_ATTRIBUTE_RE = /\s*(#{REXML::Parsers::BaseParser::UNAME_STR})\s*=\s*(["'])(.*?)\2/m
        HTML_TAG_RE = /<((?>#{REXML::Parsers::BaseParser::UNAME_STR}))\s*((?>\s+#{REXML::Parsers::BaseParser::UNAME_STR}\s*=\s*(["']).*?\3)*)\s*(\/)?>/m
        HTML_TAG_CLOSE_RE = /<\/(#{REXML::Parsers::BaseParser::NAME_STR})\s*>/m
        HTML_ENTITY_RE = /&([\w:][\-\w\d\.:]*);|&#(\d+);|&\#x([0-9a-fA-F]+);/


        HTML_PARSE_AS_BLOCK = %w{applet button blockquote colgroup dd div dl fieldset form iframe li
                               map noscript object ol table tbody thead tfoot tr td ul}
        HTML_PARSE_AS_SPAN  = %w{a abbr acronym address b bdo big cite caption del dfn dt em
                               h1 h2 h3 h4 h5 h6 i ins kbd label legend optgroup p q rb rbc
                               rp rt rtc ruby samp select small span strong sub sup th tt var}
        HTML_PARSE_AS_RAW   = %w{script math option textarea pre code}

        HTML_PARSE_AS = Hash.new {|h,k| h[k] = :raw}
        HTML_PARSE_AS_BLOCK.each {|i| HTML_PARSE_AS[i] = :block}
        HTML_PARSE_AS_SPAN.each {|i| HTML_PARSE_AS[i] = :span}
        HTML_PARSE_AS_RAW.each {|i| HTML_PARSE_AS[i] = :raw}

        # Some HTML elements like script belong to both categories (i.e. are valid in block and
        # span HTML) and don't appear therefore!
        HTML_SPAN_ELEMENTS = %w{a abbr acronym b big bdo br button cite code del dfn em i img input
                              ins kbd label option q rb rbc rp rt rtc ruby samp select small span
                              strong sub sup textarea tt var}
        HTML_BLOCK_ELEMENTS = %w{address article aside applet body button blockquote caption col colgroup dd div dl dt fieldset
                               figcaption footer form h1 h2 h3 h4 h5 h6 header hgroup hr html head iframe legend listing menu
                               li map nav ol optgroup p pre section summary table tbody td th thead tfoot tr ul}
        HTML_ELEMENTS_WITHOUT_BODY = %w{area base br col command embed hr img input keygen link meta param source track wbr}
      end


      # Contains the parsing methods. This module can be mixed into any parser to get HTML parsing
      # functionality. The only thing that must be provided by the class are instance variable
      # <tt>@stack</tt> for storing needed state and <tt>@src</tt> (instance of StringScanner) for
      # the actual parsing.
      module Parser

        include Constants

        # Process the HTML start tag that has already be scanned/checked. Does the common processing
        # steps and then yields to the caller for further processing.
        def handle_html_start_tag
          name = @src[1]
          closed = !@src[4].nil?
          attrs = {}
          @src[2].scan(HTML_ATTRIBUTE_RE).each {|attr,sep,val| attrs[attr] = val}

          el = Element.new(:html_element, name, :attr => attrs, :category => :block)
          @tree.children << el

          if !closed && HTML_ELEMENTS_WITHOUT_BODY.include?(el.value)
            warning("The HTML tag '#{el.value}' cannot have any content - auto-closing it")
            closed = true
          end
          if name == 'script'
            handle_html_script_tag
            yield(el, true)
          else
            yield(el, closed)
          end
        end

        def handle_html_script_tag
          curpos = @src.pos
          if result = @src.scan_until(/(?=<\/script\s*>)/m)
            add_text(extract_string(curpos...@src.pos, @src), @tree.children.last, :raw)
            @src.scan(HTML_TAG_CLOSE_RE)
          else
            add_text(@src.scan(/.*/m), @tree.children.last, :raw)
            warning("Found no end tag for 'script' - auto-closing it")
          end
        end

        HTML_RAW_START = /(?=<(#{REXML::Parsers::BaseParser::UNAME_STR}|\/|!--|\?))/

        # Parse raw HTML from the current source position, storing the found elements in +el+.
        # Parsing continues until one of the following criteria are fulfilled:
        #
        # - The end of the document is reached.
        # - The matching end tag for the element +el+ is found (only used if +el+ is an HTML
        #   element).
        #
        # When an HTML start tag is found, processing is deferred to #handle_html_start_tag,
        # providing the block given to this method.
        def parse_raw_html(el, &block)
          @stack.push(@tree)
          @tree = el

          done = false
          while !@src.eos? && !done
            if result = @src.scan_until(HTML_RAW_START)
              add_text(result, @tree, :text)
              if result = @src.scan(HTML_COMMENT_RE)
                @tree.children << Element.new(:xml_comment, result, :category => :block, :parent_is_raw => true)
              elsif result = @src.scan(HTML_INSTRUCTION_RE)
                @tree.children << Element.new(:xml_pi, result, :category => :block, :parent_is_raw => true)
              elsif @src.scan(HTML_TAG_RE)
                handle_html_start_tag(&block)
              elsif @src.scan(HTML_TAG_CLOSE_RE)
                if @tree.value == @src[1]
                  done = true
                else
                  warning("Found invalidly used HTML closing tag for '#{@src[1]}' - ignoring it")
                end
              else
                add_text(@src.scan(/./), @tree, :text)
              end
            else
              result = @src.scan(/.*/m)
              add_text(result, @tree, :text)
              warning("Found no end tag for '#{@tree.value}' - auto-closing it") if @tree.type == :html_element
              done = true
            end
          end

          @tree = @stack.pop
        end

      end


      # Converts HTML elements to native elements if possible.
      class ElementConverter

        include Constants
        include ::Kramdown::Utils::Entities

        REMOVE_TEXT_CHILDREN =  %w{html head hgroup ol ul dl table colgroup tbody thead tfoot tr select optgroup}
        WRAP_TEXT_CHILDREN = %w{body section nav article aside header footer address div li dd blockquote figure
                                figcaption fieldset form}
        REMOVE_WHITESPACE_CHILDREN = %w{body section nav article aside header footer address
                                        div li dd blockquote figure figcaption td th fieldset form}
        STRIP_WHITESPACE = %w{address article aside blockquote body caption dd div dl dt fieldset figcaption form footer
                              header h1 h2 h3 h4 h5 h6 legend li nav p section td th}
        SIMPLE_ELEMENTS = %w{em strong blockquote hr br a img p thead tbody tfoot tr td th ul ol dl li dl dt dd}

        def initialize(doc)
          @doc = doc
        end

        # Convert the element +el+ and its children.
        def process(el, do_conversion = true, preserve_text = false, parent = nil)
          case el.type
          when :xml_comment, :xml_pi, :html_doctype
            ptype = if parent.nil?
                      'div'
                    else
                      case parent.type
                      when :html_element then parent.value
                      when :code_span then 'code'
                      when :code_block then 'pre'
                      when :header then 'h1'
                      else parent.type.to_s
                      end
                    end
            el.options = {:category => HTML_PARSE_AS_SPAN.include?(ptype) ? :span : :block}
            return
          when :html_element
          else return
          end

          type = el.value
          remove_text_children(el) if REMOVE_TEXT_CHILDREN.include?(type)

          mname = "convert_#{el.value}"
          if do_conversion && self.class.method_defined?(mname)
            send(mname, el)
          elsif do_conversion && SIMPLE_ELEMENTS.include?(type)
            set_basics(el, type.intern, HTML_SPAN_ELEMENTS.include?(type) ? :span : :block)
            process_children(el, do_conversion, preserve_text)
          else
            process_html_element(el, do_conversion, preserve_text)
          end

          strip_whitespace(el) if STRIP_WHITESPACE.include?(type)
          remove_whitespace_children(el) if REMOVE_WHITESPACE_CHILDREN.include?(type)
          wrap_text_children(el) if WRAP_TEXT_CHILDREN.include?(type)
        end

        def process_children(el, do_conversion = true, preserve_text = false)
          el.children.map! do |c|
            if c.type == :text
              process_text(c.value, preserve_text)
            else
              process(c, do_conversion, preserve_text, el)
              c
            end
          end.flatten!
        end

        # Process the HTML text +raw+: compress whitespace (if +preserve+ is +false+) and convert
        # entities in entity elements.
        def process_text(raw, preserve = false)
          raw.gsub!(/\s+/, ' ') unless preserve
          src = StringScanner.new(raw)
          result = []
          while !src.eos?
            if tmp = src.scan_until(/(?=#{HTML_ENTITY_RE})/)
              result << Element.new(:text, tmp)
              src.scan(HTML_ENTITY_RE)
              val = src[1] || (src[2] && src[2].to_i) || src[3].hex
              result << if %w{lsquo rsquo ldquo rdquo}.include?(val)
                          Element.new(:smart_quote, val.intern)
                        elsif %w{mdash ndash hellip laquo raquo}.include?(val)
                          Element.new(:typographic_sym, val.intern)
                        else
                          Element.new(:entity, entity(val))
                        end
            else
              result << Element.new(:text, src.scan(/.*/m))
            end
          end
          result
        end

        def process_html_element(el, do_conversion = true, preserve_text = false)
          el.options = {:category => HTML_SPAN_ELEMENTS.include?(el.value) ? :span : :block,
            :parse_type => HTML_PARSE_AS[el.value],
            :attr => el.options[:attr]
          }
          process_children(el, do_conversion, preserve_text)
        end

        def remove_text_children(el)
          el.children.delete_if {|c| c.type == :text}
        end

        SPAN_ELEMENTS = [:em, :strong, :br, :a, :img, :codespan, :entity, :smart_quote, :typographic_sym, :math]

        def wrap_text_children(el)
          tmp = []
          last_is_p = false
          el.children.each do |c|
            if c.options[:category] != :block || c.type == :text
              if !last_is_p
                tmp << Element.new(:p, nil, :transparent => true)
                last_is_p = true
              end
              tmp.last.children << c
              tmp
            else
              tmp << c
              last_is_p = false
            end
          end
          el.children = tmp
        end

        def strip_whitespace(el)
          return if el.children.empty?
          if el.children.first.type == :text
            el.children.first.value.lstrip!
          end
          if el.children.last.type == :text
            el.children.last.value.rstrip!
          end
        end

        def remove_whitespace_children(el)
          i = -1
          el.children.delete_if do |c|
            i += 1
            c.type == :text && c.value.strip.empty? &&
              (i == 0 || i == el.children.length - 1 || (el.children[i-1].options[:category] == :block &&
                                                         el.children[i+1].options[:category] == :block))
          end
        end

        def set_basics(el, type, category, opts = {})
          el.type = type
          el.options = {:category => category, :attr => el.options[:attr]}.merge(opts)
          el.value = nil
        end

        def extract_text(el, raw)
          raw << el.value.to_s if el.type == :text
          el.children.each {|c| extract_text(c, raw)}
        end

        def convert_h1(el)
          set_basics(el, :header, :block, :level => el.value[1..1].to_i)
          extract_text(el, el.options[:raw_text] = '')
          process_children(el)
        end
        %w{h2 h3 h4 h5 h6}.each do |i|
          alias_method("convert_#{i}".to_sym, :convert_h1)
        end

        def convert_code(el)
          raw = ''
          extract_text(el, raw)
          result = process_text(raw, true)
          begin
            str = result.inject('') do |mem, c|
              if c.type == :text
                mem << c.value
              elsif c.type == :entity
                if RUBY_VERSION >= '1.9'
                  mem << c.value.char.encode(@doc.parse_infos[:encoding])
                elsif [60, 62, 34, 38].include?(c.value.code_point)
                  mem << c.value.code_point.chr
                end
              elsif c.type == :smart_quote || c.type == :typographic_sym
                mem << entity(c.value.to_s).char.encode(@doc.parse_infos[:encoding])
              else
                raise "Bug - please report"
              end
            end
            result.clear
            result << Element.new(:text, str)
          rescue
          end
          if result.length > 1 || result.first.type != :text
            process_html_element(el, false, true)
          else
            if el.value == 'code'
              set_basics(el, :codespan, :span)
            else
              set_basics(el, :codeblock, :block)
            end
            el.value = result.first.value
          end
        end
        alias :convert_pre :convert_code

        def convert_table(el)
          if !is_simple_table?(el)
            process_html_element(el, false)
            return
          end
          process_children(el)
          set_basics(el, :table, :block)
          el.options[:alignment] = []
          calc_alignment = lambda do |c|
            if c.type == :tr && el.options[:alignment].empty?
              el.options[:alignment] = [:default] * c.children.length
              break
            else
              c.children.each {|cc| calc_alignment.call(cc)}
            end
          end
          calc_alignment.call(el)
          if el.children.first.type == :tr
            tbody = Element.new(:tbody, nil, :category => :block)
            tbody.children = el.children
            el.children = [tbody]
          end
        end

        def is_simple_table?(el)
          only_phrasing_content = lambda do |c|
            c.children.all? do |cc|
              (cc.type == :text || !HTML_BLOCK_ELEMENTS.include?(cc.value)) && only_phrasing_content.call(cc)
            end
          end
          check_cells = Proc.new do |c|
            if c.value == 'th' || c.value == 'td'
              return false if !only_phrasing_content.call(c)
            else
              c.children.each {|cc| check_cells.call(cc)}
            end
          end
          check_cells.call(el)

          check_rows = lambda do |t, type|
            t.children.all? {|r| (r.value == 'tr' || r.type == :text) && r.children.all? {|c| c.value == type || c.type == :text}}
          end
          check_rows.call(el, 'td') ||
            (el.children.all? do |t|
               t.type == :text || (t.value == 'thead' && check_rows.call(t, 'th')) ||
                 ((t.value == 'tfoot' || t.value == 'tbody') && check_rows.call(t, 'td'))
             end && el.children.any? {|t| t.value == 'tbody'})
        end

        def convert_div(el)
          if !is_math_tag?(el)
            process_html_element(el)
          else
            handle_math_tag(el)
          end
        end
        alias :convert_span :convert_div

        def is_math_tag?(el)
          el.options[:attr] && el.options[:attr]['class'].to_s =~ /\bmath\b/ &&
            el.children.size == 1 && el.children.first.type == :text
        end

        def handle_math_tag(el)
          set_basics(el, :math, (el.value == 'div' ? :block : :span))
          el.value = el.children.shift.value
          if el.options[:attr]['class'] =~ /^\s*math\s*$/
            el.options[:attr].delete('class')
          else
            el.options[:attr]['class'].sub!(/\s?math/, '')
          end
          el.value.gsub!(/&(amp|quot|gt|lt);/) do |m|
            case m
            when '&amp;'   then '&'
            when '&quot;'  then '"'
            when '&gt;'    then '>'
            when '&lt;'    then '<'
            end
          end
        end
      end

      include Parser

      # Parse +source+ as HTML document and return the created +tree+.
      def parse(source)
        @stack = []
        @tree = Element.new(:root)
        @src = StringScanner.new(adapt_source(source))

        while true
          if result = @src.scan(/\s*#{HTML_INSTRUCTION_RE}/)
            @tree.children << Element.new(:xml_pi, result.strip, :category => :block)
          elsif result = @src.scan(/\s*#{HTML_DOCTYPE_RE}/)
            @tree.children << Element.new(:html_doctype, result.strip, :category => :block)
          elsif result = @src.scan(/\s*#{HTML_COMMENT_RE}/)
            @tree.children << Element.new(:xml_comment, result.strip, :category => :block)
          else
            break
          end
        end

        tag_handler = lambda do |c, closed|
          parse_raw_html(c, &tag_handler) if !closed
        end
        parse_raw_html(@tree, &tag_handler)

        ec = ElementConverter.new(@doc)
        @tree.children.each {|c| ec.process(c)}
        ec.remove_whitespace_children(@tree)
        @tree
      end

    end

  end

end

