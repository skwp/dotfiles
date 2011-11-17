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

require 'set'

module Kramdown

  module Converter

    # Converts a Kramdown::Document to LaTeX. This converter uses ideas from other Markdown-to-LaTeX
    # converters like Pandoc and Maruku.
    class Latex < Base

      # :stopdoc:

      # Initialize the LaTeX converter with the given Kramdown document +doc+.
      def initialize(doc)
        super
        #TODO: set the footnote counter at the beginning of the document
        @doc.options[:footnote_nr]
        @doc.conversion_infos[:packages] = Set.new
      end

      def convert(el, opts = {})
        send("convert_#{el.type}", el, opts)
      end

      def inner(el, opts)
        result = ''
        el.children.each do |inner_el|
          result << send("convert_#{inner_el.type}", inner_el, opts)
        end
        result
      end

      def convert_root(el, opts)
        inner(el, opts)
      end

      def convert_blank(el, opts)
        ""
      end

      def convert_text(el, opts)
        escape(el.value)
      end

      def convert_p(el, opts)
        "#{inner(el, opts)}\n\n"
      end

      def convert_codeblock(el, opts)
        show_whitespace = el.options[:attr] && el.options[:attr]['class'].to_s =~ /\bshow-whitespaces\b/
        lang = el.options[:attr] && el.options[:attr]['lang']
        if show_whitespace || lang
          result = "\\lstset{showspaces=%s,showtabs=%s}\n" % (show_whitespace ? ['true', 'true'] : ['false', 'false'])
          result += "\\lstset{language=#{lang}}\n" if lang
          result += "\\lstset{basicstyle=\\ttfamily\\footnotesize}\\lstset{columns=fixed,frame=tlbr}\n"
          "#{result}\\begin{lstlisting}#{attribute_list(el)}\n#{el.value}\n\\end{lstlisting}\n"
        else
          "\\begin{verbatim}#{el.value}\\end{verbatim}\n"
        end
      end

      def latex_environment(type, el, text)
        "\\begin{#{type}}#{attribute_list(el)}\n#{text}\n\\end{#{type}}\n"
      end

      def convert_blockquote(el, opts)
        latex_environment('quote', el, inner(el, opts))
      end

      HEADER_TYPES = {
        1 => 'section',
        2 => 'subsection',
        3 => 'subsubsection',
        4 => 'paragraph',
        5 => 'subparagraph',
        6 => 'subparagraph'
      }
      def convert_header(el, opts)
        type = HEADER_TYPES[el.options[:level]]
        if ((el.options[:attr] && (id = el.options[:attr]['id'])) ||
            (@doc.options[:auto_ids] && (id = generate_id(el.options[:raw_text])))) &&
            (@doc.options[:toc_depth] <= 0 || el.options[:level] <= @doc.options[:toc_depth])
          "\\hypertarget{#{id}}{}\\#{type}{#{inner(el, opts)}}\\label{#{id}}\n\n"
        else
          "\\#{type}*{#{inner(el, opts)}}\n\n"
        end
      end

      def convert_hr(el, opts)
        "\\begin{center}#{attribute_list(el)}\n\\rule{3in}{0.4pt}\n\\end{center}\n"
      end

      def convert_ul(el, opts)
        if !@doc.conversion_infos[:has_toc] && (el.options[:ial][:refs].include?('toc') rescue nil)
          @doc.conversion_infos[:has_toc] = true
          '\tableofcontents'
        else
          latex_environment(el.type == :ul ? 'itemize' : 'enumerate', el, inner(el, opts))
        end
      end
      alias :convert_ol :convert_ul

      def convert_dl(el, opts)
        latex_environment('description', el, inner(el, opts))
      end

      def convert_li(el, opts)
        "\\item #{inner(el, opts).sub(/\n+\Z/, '')}\n"
      end

      def convert_dt(el, opts)
        "\\item[#{inner(el, opts)}] "
      end

      def convert_dd(el, opts)
        "#{inner(el, opts)}\n\n"
      end

      def convert_html_element(el, opts)
        if el.value == 'i'
          "\\emph{#{inner(el, opts)}}"
        elsif el.value == 'b'
          "\\emph{#{inner(el, opts)}}"
        else
          @doc.warnings << "Can't convert HTML element"
          ''
        end
      end

      def convert_xml_comment(el, opts)
        el.value.split(/\n/).map {|l| "% #{l}"}.join("\n") + "\n"
      end

      def convert_xml_pi(el, opts)
        @doc.warnings << "Can't convert XML PI/HTML document type"
        ''
      end
      alias :convert_html_doctype :convert_xml_pi

      TABLE_ALIGNMENT_CHAR = {:default => 'l', :left => 'l', :center => 'c', :right => 'r'}

      def convert_table(el, opts)
        align = el.options[:alignment].map {|a| TABLE_ALIGNMENT_CHAR[a]}.join('|')
        "\\begin{tabular}{|#{align}|}#{attribute_list(el)}\n\\hline\n#{inner(el, opts)}\\hline\n\\end{tabular}\n\n"
      end

      def convert_thead(el, opts)
        "#{inner(el, opts)}\\hline\n"
      end

      def convert_tbody(el, opts)
        inner(el, opts)
      end

      def convert_tfoot(el, opts)
        "\\hline \\hline \n#{inner(el, opts)}"
      end

      def convert_tr(el, opts)
        el.children.map {|c| send("convert_#{c.type}", c, opts)}.join(' & ') + "\\\\\n"
      end

      def convert_td(el, opts)
        inner(el, opts)
      end
      alias :convert_th :convert_td

      def convert_comment(el, opts)
        el.value.split(/\n/).map {|l| "% #{l}"}.join("\n") + "\n"
      end

      def convert_br(el, opts)
        "\\newline\n"
      end

      def convert_a(el, opts)
        url = el.options[:attr]['href']
        if url =~ /^#/
          "\\hyperlink{#{url[1..-1]}}{#{inner(el, opts)}}"
        else
          "\\href{#{url}}{#{inner(el, opts)}}"
        end
      end

      def convert_img(el, opts)
        if el.options[:attr]['src'] =~ /^(https?|ftps?):\/\//
          @doc.warnings << "Cannot include non-local image"
          ''
        elsif !el.options[:attr]['src'].empty?
          @doc.conversion_infos[:packages] << 'graphicx'
          "\\includegraphics{#{el.options[:attr]['src']}}"
        else
          @doc.warnings << "Cannot include image with empty path"
          ''
        end
      end

      def convert_codespan(el, opts)
        "{\\tt #{escape(el.value)}}"
      end

      def convert_footnote(el, opts)
        @doc.conversion_infos[:packages] << 'fancyvrb'
        "\\footnote{#{inner(@doc.parse_infos[:footnotes][el.options[:name]][:content], opts)}}"
      end

      def convert_raw(el, opts)
        escape(el.value)
      end

      def convert_em(el, opts)
        "\\emph{#{inner(el, opts)}}"
      end

      def convert_strong(el, opts)
        "\\textbf{#{inner(el, opts)}}"
      end

      # Inspired by Maruku: entity conversion table based on the one from htmltolatex
      # (http://sourceforge.net/projects/htmltolatex/), with some small adjustments/additions
      ENTITY_CONV_TABLE = {
        913 => ['$A$'],
        914 => ['$B$'],
        915 => ['$\Gamma$'],
        916 => ['$\Delta$'],
        917 => ['$E$'],
        918 => ['$Z$'],
        919 => ['$H$'],
        920 => ['$\Theta$'],
        921 => ['$I$'],
        922 => ['$K$'],
        923 => ['$\Lambda$'],
        924 => ['$M$'],
        925 => ['$N$'],
        926 => ['$\Xi$'],
        927 => ['$O$'],
        928 => ['$\Pi$'],
        929 => ['$P$'],
        931 => ['$\Sigma$'],
        932 => ['$T$'],
        933 => ['$Y$'],
        934 => ['$\Phi$'],
        935 => ['$X$'],
        936 => ['$\Psi$'],
        937 => ['$\Omega$'],
        945 => ['$\alpha$'],
        946 => ['$\beta$'],
        947 => ['$\gamma$'],
        948 => ['$\delta$'],
        949 => ['$\epsilon$'],
        950 => ['$\zeta$'],
        951 => ['$\eta$'],
        952 => ['$\theta$'],
        953 => ['$\iota$'],
        954 => ['$\kappa$'],
        955 => ['$\lambda$'],
        956 => ['$\mu$'],
        957 => ['$\nu$'],
        958 => ['$\xi$'],
        959 => ['$o$'],
        960 => ['$\pi$'],
        961 => ['$\rho$'],
        963 => ['$\sigma$'],
        964 => ['$\tau$'],
        965 => ['$\upsilon$'],
        966 => ['$\phi$'],
        967 => ['$\chi$'],
        968 => ['$\psi$'],
        969 => ['$\omega$'],
        962 => ['$\varsigma$'],
        977 => ['$\vartheta$'],
        982 => ['$\varpi$'],
        8230 => ['\ldots'],
        8242 => ['$\prime$'],
        8254 => ['-'],
        8260 => ['/'],
        8472 => ['$\wp$'],
        8465 => ['$\Im$'],
        8476 => ['$\Re$'],
        8501 => ['$\aleph$'],
        8226 => ['$\bullet$'],
        8482 => ['$^{\rm TM}$'],
        8592 => ['$\leftarrow$'],
        8594 => ['$\rightarrow$'],
        8593 => ['$\uparrow$'],
        8595 => ['$\downarrow$'],
        8596 => ['$\leftrightarrow$'],
        8629 => ['$\hookleftarrow$'],
        8657 => ['$\Uparrow$'],
        8659 => ['$\Downarrow$'],
        8656 => ['$\Leftarrow$'],
        8658 => ['$\Rightarrow$'],
        8660 => ['$\Leftrightarrow$'],
        8704 => ['$\forall$'],
        8706 => ['$\partial$'],
        8707 => ['$\exists$'],
        8709 => ['$\emptyset$'],
        8711 => ['$\nabla$'],
        8712 => ['$\in$'],
        8715 => ['$\ni$'],
        8713 => ['$\notin$'],
        8721 => ['$\sum$'],
        8719 => ['$\prod$'],
        8722 => ['$-$'],
        8727 => ['$\ast$'],
        8730 => ['$\surd$'],
        8733 => ['$\propto$'],
        8734 => ['$\infty$'],
        8736 => ['$\angle$'],
        8743 => ['$\wedge$'],
        8744 => ['$\vee$'],
        8745 => ['$\cup$'],
        8746 => ['$\cap$'],
        8747 => ['$\int$'],
        8756 => ['$\therefore$', 'amssymb'],
        8764 => ['$\sim$'],
        8776 => ['$\approx$'],
        8773 => ['$\cong$'],
        8800 => ['$\neq$'],
        8801 => ['$\equiv$'],
        8804 => ['$\leq$'],
        8805 => ['$\geq$'],
        8834 => ['$\subset$'],
        8835 => ['$\supset$'],
        8838 => ['$\subseteq$'],
        8839 => ['$\supseteq$'],
        8836 => ['$\nsubset$', 'amssymb'],
        8853 => ['$\oplus$'],
        8855 => ['$\otimes$'],
        8869 => ['$\perp$'],
        8901 => ['$\cdot$'],
        8968 => ['$\rceil$'],
        8969 => ['$\lceil$'],
        8970 => ['$\lfloor$'],
        8971 => ['$\rfloor$'],
        9001 => ['$\rangle$'],
        9002 => ['$\langle$'],
        9674 => ['$\lozenge$', 'amssymb'],
        9824 => ['$\spadesuit$'],
        9827 => ['$\clubsuit$'],
        9829 => ['$\heartsuit$'],
        9830 => ['$\diamondsuit$'],
        38 => ['\&'],
        34 => ['"'],
        39 => ['\''],
        169 => ['\copyright'],
        60 => ['\textless{}'],
        62 => ['\textgreater{}'],
        338 => ['\OE'],
        339 => ['\oe'],
        352 => ['\v{S}'],
        353 => ['\v{s}'],
        376 => ['\"Y'],
        710 => ['\textasciicircum'],
        732 => ['\textasciitilde'],
        8211 => ['--'],
        8212 => ['---'],
        8216 => ['`'],
        8217 => ['\''],
        8220 => ['``'],
        8221 => ['\'\''],
        8224 => ['\dag'],
        8225 => ['\ddag'],
        8240 => ['\permil', 'wasysym'],
        8364 => ['\euro', 'eurosym'],
        8249 => ['\guilsinglleft'],
        8250 => ['\guilsinglright'],
        8218 => ['\quotesinglbase', 'mathcomp'],
        8222 => ['\quotedblbase', 'mathcomp'],
        402 => ['\textflorin', 'mathcomp'],
        381 => ['\v{Z}'],
        382 => ['\v{z}'],
        160 => ['\nolinebreak'],
        161 => ['\textexclamdown'],
        163 => ['\pounds'],
        164 => ['\currency', 'wasysym'],
        165 => ['\textyen', 'textcomp'],
        166 => ['\brokenvert', 'wasysym'],
        167 => ['\S'],
        171 => ['\guillemotleft'],
        187 => ['\guillemotright'],
        174 => ['\textregistered'],
        170 => ['\textordfeminine'],
        172 => ['$\neg$'],
        176 => ['$\degree$', 'mathabx'],
        177 => ['$\pm$'],
        180 => ['\''],
        181 => ['$\mu$'],
        182 => ['\P'],
        183 => ['$\cdot$'],
        186 => ['\textordmasculine'],
        162 => ['\cent', 'wasysym'],
        185 => ['$^1$'],
        178 => ['$^2$'],
        179 => ['$^3$'],
        189 => ['$\frac{1}{2}$'],
        188 => ['$\frac{1}{4}$'],
        190 => ['$\frac{3}{4}'],
        192 => ['\`A'],
        193 => ['\\\'A'],
        194 => ['\^A'],
        195 => ['\~A'],
        196 => ['\"A'],
        197 => ['\AA'],
        198 => ['\AE'],
        199 => ['\cC'],
        200 => ['\`E'],
        201 => ['\\\'E'],
        202 => ['\^E'],
        203 => ['\"E'],
        204 => ['\`I'],
        205 => ['\\\'I'],
        206 => ['\^I'],
        207 => ['\"I'],
        208 => ['$\eth$', 'amssymb'],
        209 => ['\~N'],
        210 => ['\`O'],
        211 => ['\\\'O'],
        212 => ['\^O'],
        213 => ['\~O'],
        214 => ['\"O'],
        215 => ['$\times$'],
        216 => ['\O'],
        217 => ['\`U'],
        218 => ['\\\'U'],
        219 => ['\^U'],
        220 => ['\"U'],
        221 => ['\\\'Y'],
        222 => ['\Thorn', 'wasysym'],
        223 => ['\ss'],
        224 => ['\`a'],
        225 => ['\\\'a'],
        226 => ['\^a'],
        227 => ['\~a'],
        228 => ['\"a'],
        229 => ['\aa'],
        230 => ['\ae'],
        231 => ['\cc'],
        232 => ['\`e'],
        233 => ['\\\'e'],
        234 => ['\^e'],
        235 => ['\"e'],
        236 => ['\`i'],
        237 => ['\\\'i'],
        238 => ['\^i'],
        239 => ['\"i'],
        240 => ['$\eth$'],
        241 => ['\~n'],
        242 => ['\`o'],
        243 => ['\\\'o'],
        244 => ['\^o'],
        245 => ['\~o'],
        246 => ['\"o'],
        247 => ['$\divide$'],
        248 => ['\o'],
        249 => ['\`u'],
        250 => ['\\\'u'],
        251 => ['\^u'],
        252 => ['\"u'],
        253 => ['\\\'y'],
        254 => ['\thorn', 'wasysym'],
        255 => ['\"y'],
      }
      ENTITY_CONV_TABLE.each {|k,v| ENTITY_CONV_TABLE[k] = v.unshift(v.shift + '{}')}

      def convert_entity(el, opts)
        text, package = ENTITY_CONV_TABLE[el.value.code_point]
        if text
          @doc.conversion_infos[:packages] << package if package
          text
        else
          @doc.warnings << "Couldn't find entity in substitution table!"
          ''
        end
      end

      TYPOGRAPHIC_SYMS = {
        :mdash => '---', :ndash => '--', :hellip => '\ldots{}',
        :laquo_space => '\guillemotleft{}~', :raquo_space => '~\guillemotright{}',
        :laquo => '\guillemotleft{}', :raquo => '\guillemotright{}'
      }
      def convert_typographic_sym(el, opts)
        TYPOGRAPHIC_SYMS[el.value]
      end

      SMART_QUOTE_SYMS = {:lsquo => '`', :rsquo => '\'', :ldquo => '``', :rdquo => '\'\''}
      def convert_smart_quote(el, opts)
        SMART_QUOTE_SYMS[el.value]
      end

      def convert_math(el, opts)
        @doc.conversion_infos[:packages] += %w[amssymb amsmath amsthm amsfonts]
        if el.options[:category] == :block
          if el.value =~ /\A\s*\\begin\{/
            el.value
          else
            latex_environment('displaymath', el, el.value)
          end
        else
          "$#{el.value}$"
        end
      end

      def convert_abbreviation(el, opts)
        el.value
      end

      ESCAPE_MAP = {
        "^"  => "\\^{}",
        "\\" => "\\textbackslash{}",
        "~"  => "\\ensuremath{\\sim}",
        "|"  => "\\textbar{}",
        "<"  => "\\textless{}",
        ">"  => "\\textgreater{}"
      }.merge(Hash[*("{}$%&_#".scan(/./).map {|c| [c, "\\#{c}"]}.flatten)])
      ESCAPE_RE = Regexp.union(*ESCAPE_MAP.collect {|k,v| k})

      def escape(str)
        str.gsub(ESCAPE_RE) {|m| ESCAPE_MAP[m]}
      end

      def attribute_list(el)
        attrs = (el.options[:attr] || {}).map {|k,v| v.nil? ? '' : " #{k}=\"#{v.to_s}\""}.compact.sort.join('')
        attrs = "   % #{attrs}" if !attrs.empty?
        attrs
      end

    end

  end
end
