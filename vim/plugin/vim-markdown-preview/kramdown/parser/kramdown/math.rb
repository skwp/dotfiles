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

      BLOCK_MATH_START = /^#{OPT_SPACE}(\\)?\$\$(.*?)\$\$\s*?\n/m

      # Parse the math block at the current location.
      def parse_block_math
        if @src[1]
          @src.scan(/^#{OPT_SPACE}\\/)
          return false
        end
        @src.pos += @src.matched_size
        @tree.children << new_block_el(:math, @src[2], :category => :block)
        true
      end
      define_parser(:block_math, BLOCK_MATH_START)


      INLINE_MATH_START = /\$\$(.*?)\$\$/

      # Parse the inline math at the current location.
      def parse_inline_math
        @src.pos += @src.matched_size
        @tree.children << Element.new(:math, @src[1], :category => :span)
      end
      define_parser(:inline_math, INLINE_MATH_START, '\$')

    end
  end
end
