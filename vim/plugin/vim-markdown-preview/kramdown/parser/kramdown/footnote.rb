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

require 'kramdown/parser/kramdown/attribute_list'
require 'kramdown/parser/kramdown/blank_line'
require 'kramdown/parser/kramdown/codeblock'

module Kramdown
  module Parser
    class Kramdown

      FOOTNOTE_DEFINITION_START = /^#{OPT_SPACE}\[\^(#{ALD_ID_NAME})\]:\s*?(.*?\n(?:#{BLANK_LINE}?#{CODEBLOCK_LINE})*)/

      # Parse the foot note definition at the current location.
      def parse_footnote_definition
        @src.pos += @src.matched_size

        el = Element.new(:footnote_def)
        parse_blocks(el, @src[2].gsub(INDENT, ''))
        warning("Duplicate footnote name '#{@src[1]}' - overwriting") if @doc.parse_infos[:footnotes][@src[1]]
        (@doc.parse_infos[:footnotes][@src[1]] = {})[:content] = el
        true
      end
      define_parser(:footnote_definition, FOOTNOTE_DEFINITION_START)


      FOOTNOTE_MARKER_START = /\[\^(#{ALD_ID_NAME})\]/

      # Parse the footnote marker at the current location.
      def parse_footnote_marker
        @src.pos += @src.matched_size
        fn_def = @doc.parse_infos[:footnotes][@src[1]]
        if fn_def
          valid = fn_def[:marker] && fn_def[:marker].options[:stack][0..-2].zip(fn_def[:marker].options[:stack][1..-1]).all? do |par, child|
            par.children.include?(child)
          end
          if !fn_def[:marker] || !valid
            fn_def[:marker] = Element.new(:footnote, nil, :name => @src[1])
            fn_def[:marker].options[:stack] = [@stack.map {|s| s.first}, @tree, fn_def[:marker]].flatten.compact
            @tree.children << fn_def[:marker]
          else
            warning("Footnote marker '#{@src[1]}' already appeared in document, ignoring newly found marker")
            add_text(@src.matched)
          end
        else
          warning("Footnote definition for '#{@src[1]}' not found")
          add_text(@src.matched)
        end
      end
      define_parser(:footnote_marker, FOOTNOTE_MARKER_START, '\[')

    end
  end
end
