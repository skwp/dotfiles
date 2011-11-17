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

      # Parse the string +str+ and extract all attributes and add all found attributes to the hash
      # +opts+.
      def parse_attribute_list(str, opts)
        str.scan(ALD_TYPE_ANY).each do |key, sep, val, id_attr, class_attr, ref|
          if ref
            (opts[:refs] ||= []) << ref
          elsif class_attr
            opts['class'] = ((opts['class'] || '') + " #{class_attr}").lstrip
          elsif id_attr
            opts['id'] = id_attr
          else
            opts[key] = val.gsub(/\\(\}|#{sep})/, "\\1")
          end
        end
      end

      # Update the +ial+ with the information from the inline attribute list +opts+.
      def update_ial_with_ial(ial, opts)
        (ial[:refs] ||= []) << opts[:refs]
        ial['class'] = ((ial['class'] || '') + " #{opts['class']}").lstrip if opts['class']
        opts.each {|k,v| ial[k] = v if k != :refs && k != 'class' }
      end


      ALD_ID_CHARS = /[\w\d-]/
      ALD_ANY_CHARS = /\\\}|[^\}]/
      ALD_ID_NAME = /(?:\w|\d)#{ALD_ID_CHARS}*/
      ALD_TYPE_KEY_VALUE_PAIR = /(#{ALD_ID_NAME})=("|')((?:\\\}|\\\2|[^\}\2])*?)\2/
      ALD_TYPE_CLASS_NAME = /\.(#{ALD_ID_NAME})/
      ALD_TYPE_ID_NAME = /#(#{ALD_ID_NAME})/
      ALD_TYPE_REF = /(#{ALD_ID_NAME})/
      ALD_TYPE_ANY = /(?:\A|\s)(?:#{ALD_TYPE_KEY_VALUE_PAIR}|#{ALD_TYPE_ID_NAME}|#{ALD_TYPE_CLASS_NAME}|#{ALD_TYPE_REF})(?=\s|\Z)/
      ALD_START = /^#{OPT_SPACE}\{:(#{ALD_ID_NAME}):(#{ALD_ANY_CHARS}+)\}\s*?\n/

      # Parse the attribute list definition at the current location.
      def parse_ald
        @src.pos += @src.matched_size
        parse_attribute_list(@src[2], @doc.parse_infos[:ald][@src[1]] ||= {})
        @tree.children << Element.new(:eob)
        true
      end
      define_parser(:ald, ALD_START)


      IAL_BLOCK_START = /^#{OPT_SPACE}\{:(?!:)(#{ALD_ANY_CHARS}+)\}\s*?\n/

      # Parse the inline attribute list at the current location.
      def parse_block_ial
        @src.pos += @src.matched_size
        if @tree.children.last && @tree.children.last.type != :blank && @tree.children.last.type != :eob
          parse_attribute_list(@src[1], @tree.children.last.options[:ial] ||= {})
        else
          parse_attribute_list(@src[1], @block_ial = {})
        end
        @tree.children << Element.new(:eob) unless @src.check(IAL_BLOCK_START)
        true
      end
      define_parser(:block_ial, IAL_BLOCK_START)


      IAL_SPAN_START = /\{:(#{ALD_ANY_CHARS}+)\}/

      # Parse the inline attribute list at the current location.
      def parse_span_ial
        @src.pos += @src.matched_size
        if @tree.children.last && @tree.children.last.type != :text
          attr = {}
          parse_attribute_list(@src[1], attr)
          update_ial_with_ial(@tree.children.last.options[:ial] ||= {}, attr)
          update_attr_with_ial(@tree.children.last.options[:attr] ||= {}, attr)
        else
          warning("Ignoring span IAL because preceding element is just text")
        end
      end
      define_parser(:span_ial, IAL_SPAN_START, '\{:')

    end
  end
end
