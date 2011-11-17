# FILE:     autoload/conque_term/conque_screen.py
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
ConqueScreen is an extention of the vim.current.buffer object

Unix terminal escape sequences usually reference line numbers relative to the 
top of the visible screen. However the visible portion of the Vim buffer
representing the terminal probably doesn't start at the first line of the 
buffer.

The ConqueScreen class allows access to the Vim buffer with screen-relative
line numbering. And handles a few other related tasks, such as setting the
correct cursor position.

  E.g.:
    s = ConqueScreen()
    ...
    s[5] = 'Set 5th line in terminal to this line'
    s.append('Add new line to terminal')
    s[5] = 'Since previous append() command scrolled the terminal down, this is a different line than first cb[5] call'

"""

import vim


class ConqueScreen(object):

    # the buffer
    buffer = None

    # screen and scrolling regions
    screen_top = 1

    # screen width
    screen_width = 80
    screen_height = 80

    # char encoding for vim buffer
    screen_encoding = 'utf-8'


    def __init__(self):
        """ Initialize screen size and character encoding. """

        self.buffer = vim.current.buffer

        # initialize screen size
        self.screen_top = 1
        self.screen_width = vim.current.window.width
        self.screen_height = vim.current.window.height

        # save screen character encoding type
        self.screen_encoding = vim.eval('&fileencoding')


    def __len__(self):
        """ Define the len() function for ConqueScreen objects. """
        return len(self.buffer)


    def __getitem__(self, key):
        """ Define value access for ConqueScreen objects. """
        buffer_line = self.get_real_idx(key)

        # if line is past buffer end, add lines to buffer
        if buffer_line >= len(self.buffer):
            for i in range(len(self.buffer), buffer_line + 1):
                self.append(' ')

        return u(self.buffer[buffer_line], 'utf-8')


    def __setitem__(self, key, value):
        """ Define value assignments for ConqueScreen objects. """
        buffer_line = self.get_real_idx(key)

        if CONQUE_PYTHON_VERSION == 2:
            val = value.encode(self.screen_encoding)
        else:
            # XXX / Vim's python3 interface doesn't accept bytes object
            val = str(value)

        # if line is past end of screen, append
        if buffer_line == len(self.buffer):
            self.buffer.append(val)
        else:
            self.buffer[buffer_line] = val


    def __delitem__(self, key):
        """ Define value deletion for ConqueScreen objects. """
        del self.buffer[self.screen_top + key - 2]


    def append(self, value):
        """ Define value appending for ConqueScreen objects. """

        if len(self.buffer) > self.screen_top + self.screen_height - 1:
            self.buffer[len(self.buffer) - 1] = value
        else:
            self.buffer.append(value)

        if len(self.buffer) > self.screen_top + self.screen_height - 1:
            self.screen_top += 1

        if vim.current.buffer.number == self.buffer.number:
            vim.command('normal! G')


    def insert(self, line, value):
        """ Define value insertion for ConqueScreen objects. """

        l = self.screen_top + line - 2
        try:
            self.buffer.append(value, l)
        except:
            self.buffer[l:l] = [value]


    def get_top(self):
        """ Get the Vim line number representing the top of the visible terminal. """
        return self.screen_top


    def get_real_idx(self, line):
        """ Get the zero index Vim line number corresponding to the provided screen line. """
        return (self.screen_top + line - 2)


    def get_buffer_line(self, line):
        """ Get the Vim line number corresponding to the provided screen line. """
        return (self.screen_top + line - 1)


    def set_screen_width(self, width):
        """ Set the screen width. """
        self.screen_width = width


    def clear(self):
        """ Clear the screen. Does not clear the buffer, just scrolls down past all text. """

        self.screen_width = width
        self.buffer.append(' ')
        vim.command('normal! Gzt')
        self.screen_top = len(self.buffer)


    def set_cursor(self, line, column):
        """ Set cursor position. """

        # figure out line
        buffer_line = self.screen_top + line - 1
        if buffer_line > len(self.buffer):
            for l in range(len(self.buffer) - 1, buffer_line):
                self.buffer.append('')

        # figure out column
        real_column = column
        if len(self.buffer[buffer_line - 1]) < real_column:
            self.buffer[buffer_line - 1] = self.buffer[buffer_line - 1] + ' ' * (real_column - len(self.buffer[buffer_line - 1]))

        if not CONQUE_FAST_MODE:
            # set cursor at byte index of real_column'th character
            vim.command('call cursor(' + str(buffer_line) + ', byteidx(getline(' + str(buffer_line) + '), ' + str(real_column) + '))')

        else:
            # old version
            # python version is occasionally grumpy
            try:
                vim.current.window.cursor = (buffer_line, real_column - 1)
            except:
                vim.command('call cursor(' + str(buffer_line) + ', ' + str(real_column) + ')')


    def reset_size(self, line):
        """ Change screen size """





        # save cursor line number
        buffer_line = self.screen_top + line

        # reset screen size
        self.screen_width = vim.current.window.width
        self.screen_height = vim.current.window.height
        self.screen_top = len(self.buffer) - vim.current.window.height + 1
        if self.screen_top < 1:
            self.screen_top = 1


        # align bottom of buffer to bottom of screen
        vim.command('normal! ' + str(self.screen_height) + 'kG')

        # return new relative line number
        return (buffer_line - self.screen_top)


    def align(self):
        """ align bottom of buffer to bottom of screen """
        vim.command('normal! ' + str(self.screen_height) + 'kG')


