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

  # == Parser Module
  #
  # This module contains all available parsers. Currently, there two parsers:
  #
  # * Kramdown for parsing documents in kramdown format
  # * Html for parsing HTML documents
  module Parser

    autoload :Base, 'kramdown/parser/base'
    autoload :Kramdown, 'kramdown/parser/kramdown'
    autoload :Html, 'kramdown/parser/html'

  end

end
