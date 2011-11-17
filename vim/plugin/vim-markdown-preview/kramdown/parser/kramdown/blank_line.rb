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

      BLANK_LINE = /(?:^\s*\n)+/

      # Parse the blank line at the current postition.
      def parse_blank_line
        @src.pos += @src.matched_size
        if @tree.children.last && @tree.children.last.type == :blank
          @tree.children.last.value += @src.matched
        else
          @tree.children << new_block_el(:blank, @src.matched)
        end
        true
      end
      define_parser(:blank_line, BLANK_LINE)

    end
  end
end
