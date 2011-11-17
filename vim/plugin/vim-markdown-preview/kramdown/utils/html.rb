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

  module Utils

    module HTML

      # Convert the +entity+ to a string.
      def entity_to_str(e)
        if RUBY_VERSION >= '1.9' && (c = e.char.encode(@doc.parse_infos[:encoding]) rescue nil) && !ESCAPE_MAP.has_key?(c)
          c
        elsif @doc.options[:numeric_entities] || e.name.nil?
          "&##{e.code_point};"
        else
          "&#{e.name};"
        end
      end

      # Return the string with the attributes of the element +el+.
      def html_attributes(el)
        (el.options[:attr] || {}).map {|k,v| v.nil? ? '' : " #{k}=\"#{escape_html(v.to_s, :no_entities)}\"" }.sort.join('')
      end

      ESCAPE_MAP = {
        '<' => '&lt;',
        '>' => '&gt;',
        '&' => '&amp;',
        '"' => '&quot;'
      }
      ESCAPE_ALL_RE = Regexp.union(*ESCAPE_MAP.collect {|k,v| k})
      ESCAPE_NO_ENTITIES_RE = Regexp.union(REXML::Parsers::BaseParser::REFERENCE_RE, ESCAPE_ALL_RE)
      ESCAPE_NORMAL = Regexp.union(REXML::Parsers::BaseParser::REFERENCE_RE, /<|>|&/)
      ESCAPE_RE_FROM_TYPE = {
        :all => ESCAPE_ALL_RE,
        :no_entities => ESCAPE_NO_ENTITIES_RE,
        :text => ESCAPE_NORMAL
      }

      # Escape the special HTML characters in the string +str+. The parameter +type+ specifies what
      # is escaped: <tt>:all</tt> - all special HTML characters as well as entities,
      # <tt>:no_entities</tt> - all special HTML characters but no entities, <tt>:text</tt> - all
      # special HTML characters except the quotation mark but no entities.
      def escape_html(str, type = :all)
        str.gsub(ESCAPE_RE_FROM_TYPE[type]) {|m| ESCAPE_MAP[m] || m}
      end

    end

  end

end
