# FILE:     autoload/conque_term/conque_sole.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-02
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""
Windows Console Emulator

This is the main interface to the Windows emulator. It reads new output from the background console
and updates the Vim buffer.
"""

import vim


class ConqueSole(Conque):

    window_top = None
    window_bottom = None

    color_cache = {}
    attribute_cache = {}
    color_mode = None
    color_conceals = {}

    buffer = None
    encoding = None

    # counters for periodic rendering
    buffer_redraw_ct = 1
    screen_redraw_ct = 1

    # line offset, shifts output down
    offset = 0


    def open(self):
        """ Start command and initialize this instance

        Arguments:
        command - Command string, e.g. "Powershell.exe"
        options - Dictionary of config options
        python_exe - Path to the python.exe executable. Usually C:\PythonXX\python.exe
        communicator_py - Path to subprocess controller script in user's vimfiles directory
      
        """
        # get arguments
        command = vim.eval('command')
        options = vim.eval('options')
        python_exe = vim.eval('py_exe')
        communicator_py = vim.eval('py_vim')

        # init size
        self.columns = vim.current.window.width
        self.lines = vim.current.window.height
        self.window_top = 0
        self.window_bottom = vim.current.window.height - 1

        # color mode
        self.color_mode = vim.eval('g:ConqueTerm_ColorMode')

        # line offset
        self.offset = int(options['offset'])

        # init color
        self.enable_colors = options['color'] and not CONQUE_FAST_MODE

        # open command
        self.proc = ConqueSoleWrapper()
        self.proc.open(command, self.lines, self.columns, python_exe, communicator_py, options)

        self.buffer = vim.current.buffer
        self.screen_encoding = vim.eval('&fileencoding')


    def read(self, timeout=1, set_cursor=True, return_output=False, update_buffer=True):
        """ Read from console and update Vim buffer. """

        try:
            stats = self.proc.get_stats()

            if not stats:
                return

            # disable screen and buffer redraws in fast mode
            if not CONQUE_FAST_MODE:
                self.buffer_redraw_ct += 1
                self.screen_redraw_ct += 1

            update_top = 0
            update_bottom = 0
            lines = []

            # full buffer redraw, our favorite!
            #if self.buffer_redraw_ct == CONQUE_SOLE_BUFFER_REDRAW:
            #    self.buffer_redraw_ct = 0
            #    update_top = 0
            #    update_bottom = stats['top_offset'] + self.lines
            #    (lines, attributes) = self.proc.read(update_top, update_bottom)
            #    if return_output:
            #        output = self.get_new_output(lines, update_top, stats)
            #    if update_buffer:
            #        for i in range(update_top, update_bottom + 1):
            #            if CONQUE_FAST_MODE:
            #                self.plain_text(i, lines[i], None, stats)
            #            else:
            #                self.plain_text(i, lines[i], attributes[i], stats)

            # full screen redraw
            if stats['cursor_y'] + 1 != self.l or stats['top_offset'] != self.window_top or self.screen_redraw_ct >= CONQUE_SOLE_SCREEN_REDRAW:

                self.screen_redraw_ct = 0
                update_top = self.window_top
                update_bottom = max([stats['top_offset'] + self.lines + 1, stats['cursor_y']])
                (lines, attributes) = self.proc.read(update_top, update_bottom - update_top + 1)
                if return_output:
                    output = self.get_new_output(lines, update_top, stats)
                if update_buffer:
                    for i in range(update_top, update_bottom + 1):
                        if CONQUE_FAST_MODE:
                            self.plain_text(i, lines[i - update_top], None, stats)
                        else:
                            self.plain_text(i, lines[i - update_top], attributes[i - update_top], stats)


            # single line redraw
            else:
                update_top = stats['cursor_y']
                (lines, attributes) = self.proc.read(update_top, 1)
                if return_output:
                    output = self.get_new_output(lines, update_top, stats)
                if update_buffer:
                    if lines[0].rstrip() != u(self.buffer[update_top].rstrip()):
                        if CONQUE_FAST_MODE:
                            self.plain_text(update_top, lines[0], None, stats)
                        else:
                            self.plain_text(update_top, lines[0], attributes[0], stats)


            # reset current position
            self.window_top = stats['top_offset']
            self.l = stats['cursor_y'] + 1
            self.c = stats['cursor_x'] + 1

            # reposition cursor if this seems plausible
            if set_cursor:
                self.set_cursor(self.l, self.c)

            if return_output:
                return output

        except:

            pass


    def get_new_output(self, lines, update_top, stats):
        """ Calculate the "new" output from this read. Fake but useful """

        if not (stats['cursor_y'] + 1 > self.l or (stats['cursor_y'] + 1 == self.l and stats['cursor_x'] + 1 > self.c)):
            return ""






        try:
            num_to_return = stats['cursor_y'] - self.l + 2

            lines = lines[self.l - update_top - 1:]


            new_output = []

            # first line
            new_output.append(lines[0][self.c - 1:].rstrip())

            # the rest
            for i in range(1, num_to_return):
                new_output.append(lines[i].rstrip())

        except:

            pass



        return "\n".join(new_output)


    def plain_text(self, line_nr, text, attributes, stats):
        """ Write plain text to Vim buffer. """





        # handle line offset
        line_nr += self.offset

        self.l = line_nr + 1 

        # remove trailing whitespace
        text = text.rstrip()

        # if we're using concealed text for color, then s- is weird
        if self.color_mode == 'conceal':

            text = self.add_conceal_color(text, attributes, stats, line_nr)


        # deal with character encoding
        if CONQUE_PYTHON_VERSION == 2:
            val = text.encode(self.screen_encoding)
        else:
            # XXX / Vim's python3 interface doesn't accept bytes object
            val = str(text)

        # update vim buffer
        if len(self.buffer) <= line_nr:
            self.buffer.append(val)
        else:
            self.buffer[line_nr] = val

        if self.enable_colors and not self.color_mode == 'conceal' and line_nr > self.l - CONQUE_MAX_SYNTAX_LINES:
            relevant = attributes[0:len(text)]
            if line_nr not in self.attribute_cache or self.attribute_cache[line_nr] != relevant:
                self.do_color(attributes=relevant, stats=stats)
                self.attribute_cache[line_nr] = relevant


    def add_conceal_color(self, text, attributes, stats, line_nr):
        """ Add 'conceal' color strings to output text """

        # stop here if coloration is disabled
        if not self.enable_colors:
            return text

        # if no colors for this line, clear everything out
        if len(attributes) == 0 or attributes == u(chr(stats['default_attribute'])) * len(attributes):
            return text

        new_text = ''
        self.color_conceals[line_nr] = []

        attribute_chunks = CONQUE_WIN32_REGEX_ATTR.findall(attributes)
        offset = 0
        ends = []
        for attr in attribute_chunks:
            attr_num = ord(attr[1])
            ends = []
            if attr_num != stats['default_attribute']:

                color = self.translate_color(attr_num)

                new_text += chr(27) + 'sf' + color['fg_code'] + ';'
                ends.append(chr(27) + 'ef' + color['fg_code'] + ';')
                self.color_conceals[line_nr].append(offset)

                if attr_num > 15:
                    new_text += chr(27) + 'sb' + color['bg_code'] + ';'
                    ends.append(chr(27) + 'eb' + color['bg_code'] + ';')
                    self.color_conceals[line_nr].append(offset)

            new_text += text[offset:offset + len(attr[0])]

            # close color regions
            ends.reverse()
            for i in range(0, len(ends)):
                self.color_conceals[line_nr].append(len(new_text))
                new_text += ends[i]

            offset += len(attr[0])

        return new_text


    def do_color(self, start=0, end=0, attributes='', stats=None):
        """ Convert Windows console attributes into Vim syntax highlighting """

        # if no colors for this line, clear everything out
        if len(attributes) == 0 or attributes == u(chr(stats['default_attribute'])) * len(attributes):
            self.color_changes = {}
            self.apply_color(1, len(attributes), self.l)
            return

        attribute_chunks = CONQUE_WIN32_REGEX_ATTR.findall(attributes)
        offset = 0
        for attr in attribute_chunks:
            attr_num = ord(attr[1])
            if attr_num != stats['default_attribute']:
                self.color_changes = self.translate_color(attr_num)
                self.apply_color(offset + 1, offset + len(attr[0]) + 1, self.l)
            offset += len(attr[0])


    def translate_color(self, attr):
        """ Convert Windows console attributes into RGB colors """

        # check for cached color
        if attr in self.color_cache:
            return self.color_cache[attr]






        # convert attribute integer to bit string
        bit_str = bin(attr)
        bit_str = bit_str.replace('0b', '')

        # slice foreground and background portions of bit string
        fg = bit_str[-4:].rjust(4, '0')
        bg = bit_str[-8:-4].rjust(4, '0')

        # ok, first create foreground #rbg
        red = int(fg[1]) * 204 + int(fg[0]) * int(fg[1]) * 51
        green = int(fg[2]) * 204 + int(fg[0]) * int(fg[2]) * 51
        blue = int(fg[3]) * 204 + int(fg[0]) * int(fg[3]) * 51
        fg_str = "#%02x%02x%02x" % (red, green, blue)
        fg_code = "%02x%02x%02x" % (red, green, blue)
        fg_code = fg_code[0] + fg_code[2] + fg_code[4]

        # ok, first create foreground #rbg
        red = int(bg[1]) * 204 + int(bg[0]) * int(bg[1]) * 51
        green = int(bg[2]) * 204 + int(bg[0]) * int(bg[2]) * 51
        blue = int(bg[3]) * 204 + int(bg[0]) * int(bg[3]) * 51
        bg_str = "#%02x%02x%02x" % (red, green, blue)
        bg_code = "%02x%02x%02x" % (red, green, blue)
        bg_code = bg_code[0] + bg_code[2] + bg_code[4]

        # build value for color_changes

        color = {'guifg': fg_str, 'guibg': bg_str}

        if self.color_mode == 'conceal':
            color['fg_code'] = fg_code
            color['bg_code'] = bg_code

        self.color_cache[attr] = color

        return color


    def write_vk(self, vk_code):
        """ write virtual key code to shared memory using proprietary escape seq """

        self.proc.write_vk(vk_code)


    def update_window_size(self):
        """ Resize underlying console if Vim buffer size has changed """

        if vim.current.window.width != self.columns or vim.current.window.height != self.lines:



            # reset all window size attributes to default
            self.columns = vim.current.window.width
            self.lines = vim.current.window.height
            self.working_columns = vim.current.window.width
            self.working_lines = vim.current.window.height
            self.bottom = vim.current.window.height

            self.proc.window_resize(vim.current.window.height, vim.current.window.width)


    def set_cursor(self, line, column):
        """ Update cursor position in Vim buffer """



        # handle offset
        line += self.offset

        # shift cursor position to handle concealed text
        if self.enable_colors and self.color_mode == 'conceal':
            if line - 1 in self.color_conceals:
                for c in self.color_conceals[line - 1]:
                    if c < column:
                        column += 7
                    else:
                        break



        # figure out line
        buffer_line = line
        if buffer_line > len(self.buffer):
            for l in range(len(self.buffer) - 1, buffer_line):
                self.buffer.append('')

        # figure out column
        real_column = column
        if len(self.buffer[buffer_line - 1]) < real_column:
            self.buffer[buffer_line - 1] = self.buffer[buffer_line - 1] + ' ' * (real_column - len(self.buffer[buffer_line - 1]))

        # python version is occasionally grumpy
        try:
            vim.current.window.cursor = (buffer_line, real_column - 1)
        except:
            vim.command('call cursor(' + str(buffer_line) + ', ' + str(real_column) + ')')


    def idle(self):
        """ go into idle mode """

        self.proc.idle()


    def resume(self):
        """ resume from idle mode """

        self.proc.resume()


    def close(self):
        """ end console subprocess """
        self.proc.close()


    def abort(self):
        """ end subprocess forcefully """
        self.proc.close()


    def get_buffer_line(self, line):
        """ get buffer line """
        return line


# vim:foldmethod=marker
