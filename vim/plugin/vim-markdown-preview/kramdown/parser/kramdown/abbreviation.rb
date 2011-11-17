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

      ABBREV_DEFINITION_START = /^#{OPT_SPACE}\*\[(.+?)\]:(.*?)\n/

      # Parse the link definition at the current location.
      def parse_abbrev_definition
        @src.pos += @src.matched_size
        abbrev_id, abbrev_text = @src[1], @src[2].strip
        warning("Duplicate abbreviation ID '#{abbrev_id}' - overwriting") if @doc.parse_infos[:abbrev_defs][abbrev_id]
        @doc.parse_infos[:abbrev_defs][abbrev_id] = abbrev_text
        true
      end
      define_parser(:abbrev_definition, ABBREV_DEFINITION_START)

      # Replace the abbreviation text with elements.
      def replace_abbreviations(el, regexps = nil)
        return if @doc.parse_infos[:abbrev_defs].empty?
        if !regexps
          regexps = [Regexp.union(*@doc.parse_infos[:abbrev_defs].keys.map {|k| /#{Regexp.escape(k)}/})]
          regexps << /(?=(?:\W|^)#{regexps.first}(?!\w))/ # regexp should only match on word boundaries
        end
        el.children.map! do |child|
          if child.type == :text
            result = []
            strscan = StringScanner.new(child.value)
            while temp = strscan.scan_until(regexps.last)
              temp += strscan.scan(/\W|^/)
              abbr = strscan.scan(regexps.first)
              result += [Element.new(:text, temp), Element.new(:abbreviation, abbr)]
            end
            result + [Element.new(:text, extract_string(strscan.pos..-1, strscan))]
          else
            replace_abbreviations(child, regexps)
            child
          end
        end.flatten!
      end

    end
  end
end
