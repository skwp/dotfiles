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

# All the code in this file is backported from Ruby 1.8.7 sothat kramdown works under 1.8.5

if RUBY_VERSION == '1.8.5'
  require 'rexml/parsers/baseparser'
  module REXML
    module Parsers
      class BaseParser
        UNAME_STR= "(?:#{NCNAME_STR}:)?#{NCNAME_STR}"
      end
    end
  end
end
