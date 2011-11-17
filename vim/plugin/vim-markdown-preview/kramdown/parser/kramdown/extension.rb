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

module Kramdown
  module Parser
    class Kramdown

      def parse_extension_start_tag(type)
        @src.pos += @src.matched_size

        if @src[4] || @src.matched == '{:/}'
          name = (@src[4] ? "for '#{@src[4]}' " : '')
          warning("Invalid extension stop tag #{name}found - ignoring it")
          return
        end

        ext = @src[1]
        opts = {}
        body = nil
        parse_attribute_list(@src[2] || '', opts)

        if !@src[3]
          stop_re = (type == :block ? /#{EXT_BLOCK_STOP_STR % ext}/ : /#{EXT_STOP_STR % ext}/)
          if result = @src.scan_until(stop_re)
            body = result.sub!(stop_re, '')
            body.chomp! if type == :block
          else
            warning("No stop tag for extension '#{ext}' found - treating it as extension without body")
          end
        end

        handle_extension(ext, opts, body, type)
      end

      def handle_extension(name, opts, body, type)
        case name
        when 'comment'
          @tree.children << Element.new(:comment, body, :category => type) if body.kind_of?(String)
        when 'nomarkdown'
          @tree.children << Element.new(:raw, body, :category => type) if body.kind_of?(String)
        when 'options'
          opts.select do |k,v|
            k = k.to_sym
            if Kramdown::Options.defined?(k)
              @doc.options[k] = Kramdown::Options.parse(k, v) rescue @doc.options[k]
              false
            else
              true
            end
          end.each do |k,v|
            warning("Unknown kramdown option '#{k}'")
          end
        else
          warning("Invalid extension name '#{name}' specified - ignoring extension")
        end
      end


      EXT_STOP_STR = "\\{:/(%s)?\\}"
      EXT_START_STR = "\\{::(\\w+)(?:\\s(#{ALD_ANY_CHARS}*?)|)(\\/)?\\}"
      EXT_SPAN_START = /#{EXT_START_STR}|#{EXT_STOP_STR % ALD_ID_NAME}/
      EXT_BLOCK_START = /^#{OPT_SPACE}(?:#{EXT_START_STR}|#{EXT_STOP_STR % ALD_ID_NAME})\s*?\n/
      EXT_BLOCK_STOP_STR = "^#{OPT_SPACE}#{EXT_STOP_STR}\s*?\n"

      # Parse the extension block at the current location.
      def parse_block_extension
        parse_extension_start_tag(:block)
        true
      end
      define_parser(:block_extension, EXT_BLOCK_START)


      # Parse the extension span at the current location.
      def parse_span_extension
        parse_extension_start_tag(:span)
      end
      define_parser(:span_extension, EXT_SPAN_START, '\{:[:/]')

    end
  end
end
