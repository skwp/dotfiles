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

      PARAGRAPH_START = /^#{OPT_SPACE}[^ \t].*?\n/

      # Parse the paragraph at the current location.
      def parse_paragraph
        @src.pos += @src.matched_size
        if @tree.children.last && @tree.children.last.type == :p
          @tree.children.last.children.first.value << "\n" << @src.matched.chomp
        else
          @tree.children << new_block_el(:p)
          add_text(@src.matched.lstrip.chomp, @tree.children.last)
        end
        true
      end
      define_parser(:paragraph, PARAGRAPH_START)

    end
  end
end
