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

    # == Base class for parsers
    #
    # This class serves as base class for parsers. It provides common methods that can/should be
    # used by all parsers, especially by those using StringScanner for parsing.
    #
    class Base

      # Initialize the parser with the given Kramdown document +doc+.
      def initialize(doc)
        @doc = doc
        @text_type = :text
      end
      private_class_method(:new, :allocate)

      # Parse the +source+ string into an element tree, using the information provided by the
      # Kramdown document +doc+.
      #
      # Initializes a new instance of the calling class and then calls the #parse method that must
      # be implemented by each subclass.
      def self.parse(source, doc)
        new(doc).parse(source)
      end


      # Add the given warning +text+ to the warning array of the Kramdown document.
      def warning(text)
        @doc.warnings << text
        #TODO: add position information
      end

      # Modify the string +source+ to be usable by the parser.
      def adapt_source(source)
        source.gsub(/\r\n?/, "\n").chomp + "\n"
      end

      # This helper method adds the given +text+ either to the last element in the +tree+ if it is a
      # +type+ element or creates a new text element with the given +type+.
      def add_text(text, tree = @tree, type = @text_type)
        if tree.children.last && tree.children.last.type == type
          tree.children.last.value << text
        elsif !text.empty?
          tree.children << Element.new(type, text)
        end
      end

      # Extract the part of the StringScanner +srcscan+ backed string specified by the +range+. This
      # method also works correctly under Ruby 1.9.
      def extract_string(range, strscan)
        result = nil
        if RUBY_VERSION >= '1.9'
          begin
            enc = strscan.string.encoding
            strscan.string.force_encoding('ASCII-8BIT')
            result = strscan.string[range].force_encoding(enc)
          ensure
            strscan.string.force_encoding(enc)
          end
        else
          result = strscan.string[range]
        end
        result
      end

    end

  end

end
