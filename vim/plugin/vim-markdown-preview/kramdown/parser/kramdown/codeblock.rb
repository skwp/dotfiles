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

require 'kramdown/parser/kramdown/blank_line'

module Kramdown
  module Parser
    class Kramdown

      CODEBLOCK_START = INDENT
      CODEBLOCK_LINE =  /(?:#{INDENT}.*?\S.*?\n)+/
      CODEBLOCK_MATCH = /(?:#{BLANK_LINE}?#{CODEBLOCK_LINE})*/

      # Parse the indented codeblock at the current location.
      def parse_codeblock
        @tree.children << new_block_el(:codeblock, @src.scan(CODEBLOCK_MATCH).gsub!(INDENT, ''))
        true
      end
      define_parser(:codeblock, CODEBLOCK_START)


      FENCED_CODEBLOCK_START = /^~{3,}/
      FENCED_CODEBLOCK_MATCH = /^(~{3,})\s*?\n(.*?)^\1~*\s*?\n/m

      # Parse the fenced codeblock at the current location.
      def parse_codeblock_fenced
        if @src.check(FENCED_CODEBLOCK_MATCH)
          @src.pos += @src.matched_size
          @tree.children << new_block_el(:codeblock, @src[2])
          true
        else
          false
        end
      end
      define_parser(:codeblock_fenced, FENCED_CODEBLOCK_START)

    end
  end
end
