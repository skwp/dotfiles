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

      BLOCKQUOTE_START = /^#{OPT_SPACE}> ?/
      BLOCKQUOTE_MATCH = /(^#{OPT_SPACE}>.*?\n)+/

      # Parse the blockquote at the current location.
      def parse_blockquote
        result = @src.scan(BLOCKQUOTE_MATCH).gsub(BLOCKQUOTE_START, '')
        el = new_block_el(:blockquote)
        @tree.children << el
        parse_blocks(el, result)
        true
      end
      define_parser(:blockquote, BLOCKQUOTE_START)

    end
  end
end
