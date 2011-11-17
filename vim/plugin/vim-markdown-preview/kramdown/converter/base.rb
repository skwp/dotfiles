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

require 'erb'

module Kramdown

  module Converter

    # == Base class for converters
    #
    # This class serves as base class for all converters. It provides methods that can/should be
    # used by all converters (like #generate_id) as well as common functionality that is
    # automatically applied to the result (for example, embedding the output into a template).
    #
    # == Implementing a converter
    #
    # Implementing a new converter is rather easy: just create a new sub class from this class and
    # put it in the Kramdown::Converter module (the latter is only needed if auto-detection should
    # work properly). Then you need to implement the #convert(tree) method which takes a document
    # tree and should return the converted output.
    #
    # The document instance is automatically set as @doc in Base#initialize. Furthermore, the
    # document instance provides a hash called `conversion_infos` that is also automatically cleared
    # and can be used to store information about the conversion process.
    #
    # The actual transformation of the document tree can be done in any way. However, writing one
    # method per tree element type is a straight forward way to do it - this is how the Html and
    # Latex converters do the transformation.
    class Base

      # Initialize the converter with the given Kramdown document +doc+.
      def initialize(doc)
        @doc = doc
        @doc.conversion_infos.clear
      end
      private_class_method(:new, :allocate)

      # Convert the Kramdown document +doc+ to the output format implemented by a subclass.
      #
      # Initializes a new instance of the calling class and then calls the #convert method that must
      # be implemented by each subclass. If the +template+ option is specified and non-empty, the
      # result is rendered into the specified template.
      def self.convert(doc)
        result = new(doc).convert(doc.tree)
        result = apply_template(doc, result) if !doc.options[:template].empty?
        result
      end

      # Apply the template specified in the +doc+ options, using +body+ as the body string.
      def self.apply_template(doc, body)
        erb = ERB.new(get_template(doc.options[:template]))
        obj = Object.new
        obj.instance_variable_set(:@doc, doc)
        obj.instance_variable_set(:@body, body)
        erb.result(obj.instance_eval{binding})
      end

      # Return the template specified by +template+.
      def self.get_template(template)
        format_ext = '.' + self.name.split(/::/).last.downcase
        shipped = File.join(::Kramdown.data_dir, template + format_ext)
        if File.exist?(template)
          File.read(template)
        elsif File.exist?(template + format_ext)
          File.read(template + format_ext)
        elsif File.exist?(shipped)
          File.read(shipped)
        else
          raise "The specified template file #{template} does not exist"
        end
      end


      # Generate an unique alpha-numeric ID from the the string +str+ for use as header ID.
      def generate_id(str)
        gen_id = str.gsub(/[^a-zA-Z0-9 -]/, '').gsub(/^[^a-zA-Z]*/, '').gsub(' ', '-').downcase
        gen_id = 'section' if gen_id.length == 0
        @used_ids ||= {}
        if @used_ids.has_key?(gen_id)
          gen_id += '-' + (@used_ids[gen_id] += 1).to_s
        else
          @used_ids[gen_id] = 0
        end
        @doc.options[:auto_id_prefix] + gen_id
      end

    end

  end

end
