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

      HR_START = /^#{OPT_SPACE}(\*|-|_)[ \t]*\1[ \t]*\1[ \t]*(\1|[ \t])*\n/

      # Parse the horizontal rule at the current location.
      def parse_horizontal_rule
        @src.pos += @src.matched_size
        @tree.children << new_block_el(:hr)
        true
      end
      define_parser(:horizontal_rule, HR_START)

    end
  end
end
