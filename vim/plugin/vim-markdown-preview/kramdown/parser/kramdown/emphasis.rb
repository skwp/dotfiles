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

      EMPHASIS_START = /(?:\*\*?|__?)/

      # Parse the emphasis at the current location.
      def parse_emphasis
        result = @src.scan(EMPHASIS_START)
        element = (result.length == 2 ? :strong : :em)
        type = (result =~ /_/ ? '_' : '*')
        reset_pos = @src.pos

        if (type == '_' && @src.pre_match =~ /[[:alpha:]]\z/ && @src.check(/[[:alpha:]]/)) || @src.check(/\s/) ||
            @tree.type == element || @stack.any? {|el, _| el.type == element}
          add_text(result)
          return
        end

        sub_parse = lambda do |delim, elem|
          el = Element.new(elem)
          stop_re = /#{Regexp.escape(delim)}/
          found = parse_spans(el, stop_re) do
            (@src.pre_match[-1, 1] !~ /\s/) &&
              (elem != :em || !@src.match?(/#{Regexp.escape(delim*2)}(?!#{Regexp.escape(delim)})/)) &&
              (type != '_' || !@src.match?(/#{Regexp.escape(delim)}[[:alpha:]]/)) && el.children.size > 0
          end
          [found, el, stop_re]
        end

        found, el, stop_re = sub_parse.call(result, element)
        if !found && element == :strong && @tree.type != :em
          @src.pos = reset_pos - 1
          found, el, stop_re = sub_parse.call(type, :em)
        end
        if found
          @src.scan(stop_re)
          @tree.children << el
        else
          @src.pos = reset_pos
          add_text(result)
        end
      end
      define_parser(:emphasis, EMPHASIS_START, '\*|_')

    end
  end
end
