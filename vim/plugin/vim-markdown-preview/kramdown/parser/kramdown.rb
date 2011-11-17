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

require 'strscan'
require 'stringio'

#TODO: use [[:alpha:]] in all regexp to allow parsing of international values in 1.9.1
#NOTE: use @src.pre_match only before other check/match?/... operations, otherwise the content is changed

module Kramdown

  module Parser

    # Used for parsing a document in kramdown format.
    #
    # If you want to extend the functionality of the parser, you need to the following:
    #
    # * Create a new subclass
    # * add the needed parser methods
    # * modify the @block_parsers and @span_parsers variables and add the names of your parser
    #   methods
    #
    # Here is a small example for an extended parser class that parses ERB style tags as raw text if
    # they are used as span level elements (an equivalent block level parser should probably also be
    # made to handle the block case):
    #
    #   require 'kramdown/parser/kramdown'
    #
    #   class Kramdown::Parser::ERBKramdown < Kramdown::Parser::Kramdown
    #
    #      def initialize(doc)
    #        super(doc)
    #        @span_parsers.unshift(:erb_tags)
    #      end
    #
    #      ERB_TAGS_START = /<%.*?%>/
    #
    #      def parse_erb_tags
    #        @src.pos += @src.matched_size
    #        @tree.children << Element.new(:raw, @src.matched)
    #      end
    #      define_parser(:erb_tags, ERB_TAGS_START, '<%')
    #
    #   end
    #
    # The new parser can be used like this:
    #
    #   require 'kramdown/document'
    #   # require the file with the above parser class
    #
    #   Kramdown::Document.new(input_text, :input => 'ERBKramdown').to_html
    #
    class Kramdown < Base

      include ::Kramdown

      attr_reader :tree
      attr_reader :doc
      attr_reader :options

      # Create a new Kramdown parser object for the Kramdown::Document +doc+.
      def initialize(doc)
        super(doc)

        @src = nil
        @tree = nil
        @stack = []
        @text_type = :raw_text
        @block_ial = nil

        @doc.parse_infos[:ald] = {}
        @doc.parse_infos[:link_defs] = {}
        @doc.parse_infos[:abbrev_defs] = {}
        @doc.parse_infos[:footnotes] = {}

        @block_parsers = [:blank_line, :codeblock, :codeblock_fenced, :blockquote, :table, :atx_header,
                          :setext_header, :horizontal_rule, :list, :definition_list, :link_definition, :block_html,
                          :footnote_definition, :abbrev_definition, :ald, :block_math,
                          :block_extension, :block_ial, :eob_marker, :paragraph]
        @span_parsers =  [:emphasis, :codespan, :autolink, :span_html, :footnote_marker, :link, :smart_quotes, :inline_math,
                         :span_extension, :span_ial, :html_entity, :typographic_syms, :line_break, :escaped_chars]

      end
      private_class_method(:new, :allocate)


      # The source string provided on initialization is parsed and the created +tree+ is returned.
      def parse(source)
        configure_parser
        tree = Element.new(:root)
        parse_blocks(tree, adapt_source(source))
        update_tree(tree)
        replace_abbreviations(tree)
        @doc.parse_infos[:footnotes].each do |name, data|
          update_tree(data[:content])
        end
        tree
      end

      #######
      protected
      #######

      # Adapt the object to allow parsing like specified in the options.
      def configure_parser
        @parsers = {}
        (@block_parsers + @span_parsers).each do |name|
          if self.class.has_parser?(name)
            @parsers[name] = self.class.parser(name)
          else
            raise Kramdown::Error, "Unknown parser: #{name}"
          end
        end
        @span_start, @span_start_re = span_parser_regexps
      end

      # Create the needed span parser regexps.
      def span_parser_regexps(parsers = @span_parsers)
        span_start = /#{parsers.map {|name| @parsers[name].span_start}.join('|')}/
        [span_start, /(?=#{span_start})/]
      end

      # Parse all block level elements in +text+ into the element +el+.
      def parse_blocks(el, text = nil)
        @stack.push([@tree, @src])
        @tree, @src = el, (text.nil? ? @src : StringScanner.new(text))

        status = catch(:stop_block_parsing) do
          while !@src.eos?
            block_ial_set = @block_ial
            @block_parsers.any? do |name|
              if @src.check(@parsers[name].start_re)
                send(@parsers[name].method)
              else
                false
              end
            end || begin
              warning('Warning: this should not occur - no block parser handled the line')
              add_text(@src.scan(/.*\n/))
            end
            @block_ial = nil if block_ial_set
          end
        end

        @tree, @src = *@stack.pop
        status
      end

      # Update the tree by parsing all <tt>:raw_text</tt> elements with the span level parser
      # (resets +@tree+, +@src+ and the +@stack+) and by updating the attributes from the IALs.
      def update_tree(element)
        element.children.map! do |child|
          if child.type == :raw_text
            @stack, @tree, @text_type = [], nil, :text
            @src = StringScanner.new(child.value)
            parse_spans(child)
            child.children
          elsif child.type == :eob
            []
          else
            update_tree(child)
            update_attr_with_ial(child.options[:attr] ||= {}, child.options[:ial]) if child.options[:ial]
            child
          end
        end.flatten!
      end

      # Parse all span level elements in the source string.
      def parse_spans(el, stop_re = nil, parsers = nil, text_type = @text_type)
        @stack.push([@tree, @text_type]) unless @tree.nil?
        @tree, @text_type = el, text_type

        span_start = @span_start
        span_start_re = @span_start_re
        span_start, span_start_re = span_parser_regexps(parsers) if parsers
        parsers = parsers || @span_parsers

        used_re = (stop_re.nil? ? span_start_re : /(?=#{Regexp.union(stop_re, span_start)})/)
        stop_re_found = false
        while !@src.eos? && !stop_re_found
          if result = @src.scan_until(used_re)
            add_text(result)
            if stop_re && (stop_re_matched = @src.check(stop_re))
              stop_re_found = (block_given? ? yield : true)
            end
            processed = parsers.any? do |name|
              if @src.check(@parsers[name].start_re)
                send(@parsers[name].method)
                true
              else
                false
              end
            end unless stop_re_found
            add_text(@src.scan(/./)) if !processed && !stop_re_found
          else
            add_text(@src.scan(/.*/m)) unless stop_re
            break
          end
        end

        @tree, @text_type = @stack.pop

        stop_re_found
      end

      # Update the attributes with the information from the inline attribute list and all referenced ALDs.
      def update_attr_with_ial(attr, ial)
        ial[:refs].each do |ref|
          update_attr_with_ial(attr, ref) if ref = @doc.parse_infos[:ald][ref]
        end if ial[:refs]
        attr['class'] = ((attr['class'] || '') + " #{ial['class']}").lstrip if ial['class']
        ial.each {|k,v| attr[k] = v if k.kind_of?(String) && k != 'class' }
      end

      # Create a new block level element, taking care of applying a preceding block IAL if it exists.
      def new_block_el(*args)
        el = Element.new(*args)
        el.options[:category] ||= :block
        el.options[:ial] = @block_ial if @block_ial && el.type != :blank && el.type != :eob
        el
      end

      @@parsers = {}

      # Holds all the needed data for one block/span level parser.
      Data = Struct.new(:name, :start_re, :span_start, :method)

      # Add a parser method
      #
      # * with the given +name+,
      # * using +start_re+ as start regexp
      # * and, for span parsers, +span_start+ as a String that can be used in a regexp and
      #   which identifies the starting character(s)
      #
      # to the registry. The method name is automatically derived from the +name+ or can explicitly
      # be set by using the +meth_name+ parameter.
      def self.define_parser(name, start_re, span_start = nil, meth_name = "parse_#{name}")
        raise "A parser with the name #{name} already exists!" if @@parsers.has_key?(name)
        @@parsers[name] = Data.new(name, start_re, span_start, meth_name)
      end

      # Return the Data structure for the parser +name+.
      def self.parser(name = nil)
        @@parsers[name]
      end

      # Return +true+ if there is a parser called +name+.
      def self.has_parser?(name)
        @@parsers.has_key?(name)
      end

      INDENT = /^(?:\t| {4})/
      OPT_SPACE = / {0,3}/

      require 'kramdown/parser/kramdown/blank_line'
      require 'kramdown/parser/kramdown/eob'
      require 'kramdown/parser/kramdown/paragraph'
      require 'kramdown/parser/kramdown/header'
      require 'kramdown/parser/kramdown/blockquote'
      require 'kramdown/parser/kramdown/table'
      require 'kramdown/parser/kramdown/codeblock'
      require 'kramdown/parser/kramdown/horizontal_rule'
      require 'kramdown/parser/kramdown/list'
      require 'kramdown/parser/kramdown/link'
      require 'kramdown/parser/kramdown/attribute_list'
      require 'kramdown/parser/kramdown/extension'
      require 'kramdown/parser/kramdown/footnote'
      require 'kramdown/parser/kramdown/html'
      require 'kramdown/parser/kramdown/escaped_chars'
      require 'kramdown/parser/kramdown/html_entity'
      require 'kramdown/parser/kramdown/line_break'
      require 'kramdown/parser/kramdown/typographic_symbol'
      require 'kramdown/parser/kramdown/autolink'
      require 'kramdown/parser/kramdown/codespan'
      require 'kramdown/parser/kramdown/emphasis'
      require 'kramdown/parser/kramdown/smart_quotes'
      require 'kramdown/parser/kramdown/math'
      require 'kramdown/parser/kramdown/abbreviation'

    end

  end

end
