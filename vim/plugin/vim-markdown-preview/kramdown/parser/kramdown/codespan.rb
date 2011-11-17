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

      CODESPAN_DELIMITER = /`+/

      # Parse the codespan at the current scanner location.
      def parse_codespan
        result = @src.scan(CODESPAN_DELIMITER)
        simple = (result.length == 1)
        reset_pos = @src.pos

        if simple && @src.pre_match =~ /\s\Z/ && @src.match?(/\s/)
          add_text(result)
          return
        end

        text = @src.scan_until(/#{result}/)
        if text
          text.sub!(/#{result}\Z/, '')
          if !simple
            text = text[1..-1] if text[0..0] == ' '
            text = text[0..-2] if text[-1..-1] == ' '
          end
          @tree.children << Element.new(:codespan, text)
        else
          @src.pos = reset_pos
          add_text(result)
        end
      end
      define_parser(:codespan, CODESPAN_DELIMITER, '`')

    end
  end
end
