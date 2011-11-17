# FILE:     autoload/conque_term/conque.py 
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
Vim terminal emulator.

This class is the main interface between Vim and the terminal application. It 
handles both updating the Vim buffer with new output and accepting new keyboard
input from the Vim user.

Although this class was originally designed for a Unix terminal environment, it
has been extended by the ConqueSole class for Windows.

Usage:
    term = Conque()
    term.open('/bin/bash', {'TERM': 'vt100'})
    term.write("ls -lha\r")
    term.read()
    term.close()
"""

import vim
import re
import math


class Conque:

    # screen object
    screen = None

    # subprocess object
    proc = None

    # terminal dimensions and scrolling region
    columns = 80 # same as $COLUMNS
    lines = 24 # same as $LINES
    working_columns = 80 # can be changed by CSI ? 3 l/h
    working_lines = 24 # can be changed by CSI r

    # top/bottom of the scroll region
    top = 1 # relative to top of screen
    bottom = 24 # relative to top of screen

    # cursor position
    l = 1 # current cursor line
    c = 1 # current cursor column

    # autowrap mode
    autowrap = True

    # absolute coordinate mode
    absolute_coords = True

    # tabstop positions
    tabstops = []

    # enable colors
    enable_colors = True

    # color changes
    color_changes = {}

    # color history
    color_history = {}

    # color highlight cache
    highlight_groups = {}

    # prune terminal colors
    color_pruning = True

    # don't wrap table output
    unwrap_tables = True

    # wrap CUF/CUB around line breaks
    wrap_cursor = False

    # do we need to move the cursor?
    cursor_set = False

    # current character set, ascii or graphics
    character_set = 'ascii'

    # used for auto_read actions
    read_count = 0

    # input buffer, array of ordinals
    input_buffer = []

    def open(self):
        """ Start program and initialize this instance. 

        Arguments:
        command -- Command string to execute, e.g. '/bin/bash --login'
        options -- Dictionary of environment vars to set and other options.

        """
        # get arguments
        command = vim.eval('command')
        options = vim.eval('options')

        # create terminal screen instance
        self.screen = ConqueScreen()

        # int vars
        self.columns = vim.current.window.width
        self.lines = vim.current.window.height
        self.working_columns = vim.current.window.width
        self.working_lines = vim.current.window.height
        self.bottom = vim.current.window.height

        # offset first line to make room for startup messages
        if int(options['offset']) > 0:
            self.l = int(options['offset'])

        # init color
        self.enable_colors = options['color'] and not CONQUE_FAST_MODE

        # init tabstops
        self.init_tabstops()

        # open command
        self.proc = ConqueSubprocess()
        self.proc.open(command, {'TERM': options['TERM'], 'CONQUE': '1', 'LINES': str(self.lines), 'COLUMNS': str(self.columns)})

        # send window size signal, in case LINES/COLUMNS is ignored
        self.update_window_size(True)


    def write(self, input, set_cursor=True, read=True):
        """ Write a unicode string to the subprocess. 

        set_cursor -- Position the cursor in the current buffer when finished
        read -- Check program for new output when finished

        """
        # write and read
        self.proc.write(input)

        # read output immediately
        if read:
            self.read(1, set_cursor)



    def write_ord(self, input, set_cursor=True, read=True):
        """ Write a single character to the subprocess, using an unicode ordinal. """

        if CONQUE_PYTHON_VERSION == 2:
            self.write(unichr(input), set_cursor, read)
        else:
            self.write(chr(input), set_cursor, read)
        


    def write_expr(self, expr, set_cursor=True, read=True):
        """ Write the value of a Vim expression to the subprocess. """

        if CONQUE_PYTHON_VERSION == 2:
            try:
                val = vim.eval(expr)
                self.write(unicode(val, CONQUE_VIM_ENCODING, 'ignore'), set_cursor, read)
            except:

                pass
        else:
            try:
                # XXX - Depending on Vim to deal with encoding, sadly
                self.write(vim.eval(expr), set_cursor, read)
            except:

                pass


    def write_latin1(self, input, set_cursor=True, read=True):
        """ Write latin-1 string to conque. Very ugly, shood be removed. """
        # XXX - this whole method is a hack, to be removed soon

        if CONQUE_PYTHON_VERSION == 2:
            try:
                input_unicode = input.decode('latin-1', 'ignore')
                self.write(input_unicode.encode('utf-8', 'ignore'), set_cursor, read)
            except:
                return
        else:
            self.write(input, set_cursor, read)


    def write_buffered_ord(self, chr):
        """ Add character ordinal to input buffer. In case we're not allowed to modify buffer a time of input. """
        self.input_buffer.append(chr)


    def read(self, timeout=1, set_cursor=True, return_output=False, update_buffer=True):
        """ Read new output from the subprocess and update the Vim buffer.

        Arguments:
        timeout -- Milliseconds to wait before reading input
        set_cursor -- Set the cursor position in the current buffer when finished
        return_output -- Return new subprocess STDOUT + STDERR as a string
        update_buffer -- Update the current Vim buffer with the new output

        This method goes through the following rough steps:
            1. Get new output from subprocess
            2. Split output string into control codes, escape sequences, or plain text
            3. Loop over and process each chunk, updating the Vim buffer as we go

        """
        output = ''

        # this may not actually work
        try:

            # read from subprocess and strip null characters
            output = self.proc.read(timeout)

            if output == '':
                return

            # for bufferless terminals
            if not update_buffer:
                return output



            # strip null characters. I'm still not sure why they appear
            output = output.replace(chr(0), '')

            # split input into individual escape sequences, control codes, and text output
            chunks = CONQUE_SEQ_REGEX.split(output)



            # if there were no escape sequences, skip processing and treat entire string as plain text
            if len(chunks) == 1:
                self.plain_text(chunks[0])

            # loop through and process escape sequences
            else:
                for s in chunks:
                    if s == '':
                        continue




                    # Check for control character match 
                    if CONQUE_SEQ_REGEX_CTL.match(s[0]):

                        nr = ord(s[0])
                        if nr in CONQUE_CTL:
                            getattr(self, 'ctl_' + CONQUE_CTL[nr])()
                        else:

                            pass

                    # check for escape sequence match 
                    elif CONQUE_SEQ_REGEX_CSI.match(s):

                        if s[-1] in CONQUE_ESCAPE:
                            csi = self.parse_csi(s[2:])

                            getattr(self, 'csi_' + CONQUE_ESCAPE[s[-1]])(csi)
                        else:

                            pass

                    # check for title match 
                    elif CONQUE_SEQ_REGEX_TITLE.match(s):

                        self.change_title(s[2], s[4:-1])

                    # check for hash match 
                    elif CONQUE_SEQ_REGEX_HASH.match(s):

                        if s[-1] in CONQUE_ESCAPE_HASH:
                            getattr(self, 'hash_' + CONQUE_ESCAPE_HASH[s[-1]])()
                        else:

                            pass

                    # check for charset match 
                    elif CONQUE_SEQ_REGEX_CHAR.match(s):

                        if s[-1] in CONQUE_ESCAPE_CHARSET:
                            getattr(self, 'charset_' + CONQUE_ESCAPE_CHARSET[s[-1]])()
                        else:

                            pass

                    # check for other escape match 
                    elif CONQUE_SEQ_REGEX_ESC.match(s):

                        if s[-1] in CONQUE_ESCAPE_PLAIN:
                            getattr(self, 'esc_' + CONQUE_ESCAPE_PLAIN[s[-1]])()
                        else:

                            pass

                    # else process plain text 
                    else:
                        self.plain_text(s)

            # set cusor position
            if set_cursor:
                self.screen.set_cursor(self.l, self.c)

            # we need to set the cursor position
            self.cursor_set = False

        except:


            pass

        if return_output:
            if CONQUE_PYTHON_VERSION == 3:
                return output
            else:
                return output.encode(CONQUE_VIM_ENCODING, 'replace')


    def auto_read(self):
        """ Poll program for more output. 

        Since Vim doesn't have a reliable event system that can be triggered when new
        output is available, we have to continually poll the subprocess instead. This
        method is called many times a second when the terminal buffer is active, so it
        needs to be very fast and efficient.

        The feedkeys portion is required to reset Vim's timer system. The timer is used
        to execute this command, typically set to go off after 50 ms of inactivity.

        """
        # process buffered input if any
        if len(self.input_buffer):
            for chr in self.input_buffer:
                self.write_ord(chr, set_cursor=False, read=False)
            self.input_buffer = []
            self.read(1)

        # check subprocess status, but not every time since it's CPU expensive
        if self.read_count % 32 == 0:
            if not self.proc.is_alive():
                vim.command('call conque_term#get_instance().close()')
                return

            if self.read_count > 512:
                self.read_count = 0

                # trim color history occasionally if desired
                if self.enable_colors and self.color_pruning:
                    self.prune_colors()

        # ++
        self.read_count += 1

        # read output
        self.read(1)

        # reset timer
        if self.c == 1:
            vim.command('call feedkeys("\<right>\<left>", "n")')
        else:
            vim.command('call feedkeys("\<left>\<right>", "n")')

        # stop here if cursor doesn't need to be moved
        if self.cursor_set:
            return

        # check if window size has changed
        if not CONQUE_FAST_MODE:
            self.update_window_size()


        # otherwise set cursor position
        try:
            self.set_cursor(self.l, self.c)
        except:


            pass

        self.cursor_set = True


    def plain_text(self, input):
        """ Write text output to Vim buffer.

  
        This method writes a string of characters without any control characters or escape sequences
        to the Vim buffer. In simple terms, it writes the input string to the buffer starting at the
        current cursor position, wrapping the text to a new line if needed. It also triggers the 
        terminal coloring methods if needed.


        """
        # translate input into graphics character set if needed
        if self.character_set == 'graphics':
            old_input = input
            input = u('')
            for i in range(0, len(old_input)):
                chrd = ord(old_input[i])


                try:
                    if chrd > 255:

                        input = input + old_input[i]
                    else:
                        input = input + uchr(CONQUE_GRAPHICS_SET[chrd])
                except:

                    pass



        # get current line from Vim buffer
        current_line = self.screen[self.l]

        # pad current line with spaces, if it's shorter than cursor position
        if len(current_line) < self.c:
            current_line = current_line + ' ' * (self.c - len(current_line))

        # if line is wider than screen
        if self.c + len(input) - 1 > self.working_columns:

            # Table formatting hack
            if self.unwrap_tables and CONQUE_TABLE_OUTPUT.match(input):
                self.screen[self.l] = current_line[:self.c - 1] + input + current_line[self.c + len(input) - 1:]
                self.apply_color(self.c, self.c + len(input))
                self.c += len(input)
                return


            diff = self.c + len(input) - self.working_columns - 1

            # if autowrap is enabled
            if self.autowrap:
                self.screen[self.l] = current_line[:self.c - 1] + input[:-1 * diff]
                self.apply_color(self.c, self.working_columns)
                self.ctl_nl()
                self.ctl_cr()
                remaining = input[-1 * diff:]

                self.plain_text(remaining)
            else:
                self.screen[self.l] = current_line[:self.c - 1] + input[:-1 * diff - 1] + input[-1]
                self.apply_color(self.c, self.working_columns)
                self.c = self.working_columns

        # no autowrap
        else:
            self.screen[self.l] = current_line[:self.c - 1] + input + current_line[self.c + len(input) - 1:]
            self.apply_color(self.c, self.c + len(input))
            self.c += len(input)



    def apply_color(self, start, end, line=0):
        """ Apply terminal colors to buffer for a range of characters in a single line. 

        When a text attribute escape sequence is encountered during input processing, the
        attributes are recorded in the dictionary self.color_changes. After those attributes
        have been applied, the changes are recorded in a second dictionary self.color_history.

  
        This method inspects both dictionaries to calculate any syntax highlighting 
        that needs to be executed to render the text attributes in the Vim buffer.


        """


        # stop here if coloration is disabled
        if not self.enable_colors:
            return

        # allow custom line nr to be passed
        if line:
            buffer_line = line
        else:
            buffer_line = self.get_buffer_line(self.l)

        # check for previous overlapping coloration

        to_del = []
        if buffer_line in self.color_history:
            for i in range(len(self.color_history[buffer_line])):
                syn = self.color_history[buffer_line][i]

                if syn['start'] >= start and syn['start'] < end:

                    vim.command('syn clear ' + syn['name'])
                    to_del.append(i)
                    # outside
                    if syn['end'] > end:

                        self.exec_highlight(buffer_line, end, syn['end'], syn['highlight'])
                elif syn['end'] > start and syn['end'] <= end:

                    vim.command('syn clear ' + syn['name'])
                    to_del.append(i)
                    # outside
                    if syn['start'] < start:

                        self.exec_highlight(buffer_line, syn['start'], start, syn['highlight'])

        # remove overlapped colors
        if len(to_del) > 0:
            to_del.reverse()
            for di in to_del:
                del self.color_history[buffer_line][di]

        # if there are no new colors
        if len(self.color_changes) == 0:
            return

        # build the color attribute string
        highlight = ''
        for attr in self.color_changes.keys():
            highlight = highlight + ' ' + attr + '=' + self.color_changes[attr]

        # execute the highlight
        self.exec_highlight(buffer_line, start, end, highlight)


    def exec_highlight(self, buffer_line, start, end, highlight):
        """ Execute the Vim commands for a single syntax highlight """

        syntax_name = 'ConqueHighLightAt_%d_%d_%d_%d' % (self.proc.pid, self.l, start, len(self.color_history) + 1)
        syntax_options = 'contains=ALLBUT,ConqueString,MySQLString,MySQLKeyword oneline'
        syntax_region = 'syntax match %s /\%%%dl\%%>%dc.\{%d}\%%<%dc/ %s' % (syntax_name, buffer_line, start - 1, end - start, end + 1, syntax_options)

        # check for cached highlight group
        hgroup = 'ConqueHL_%d' % (abs(hash(highlight)))
        if hgroup not in self.highlight_groups:
            syntax_group = 'highlight %s %s' % (hgroup, highlight)
            self.highlight_groups[hgroup] = hgroup
            vim.command(syntax_group)

        # link this syntax match to existing highlight group
        syntax_highlight = 'highlight link %s %s' % (syntax_name, self.highlight_groups[hgroup])



        vim.command(syntax_region)
        vim.command(syntax_highlight)

        # add syntax name to history
        if not buffer_line in self.color_history:
            self.color_history[buffer_line] = []

        self.color_history[buffer_line].append({'name': syntax_name, 'start': start, 'end': end, 'highlight': highlight})


    def prune_colors(self):
        """ Remove old syntax highlighting from the Vim buffer

        The kind of syntax highlighting required for terminal colors can make
        Conque run slowly. The prune_colors() method will remove old highlight definitions
        to keep the maximum number of highlight rules within a reasonable range.

        """


        buffer_line = self.get_buffer_line(self.l)
        ks = list(self.color_history.keys())

        for line in ks:
            if line < buffer_line - CONQUE_MAX_SYNTAX_LINES:
                for syn in self.color_history[line]:
                    vim.command('syn clear ' + syn['name'])
                del self.color_history[line]




    ###############################################################################################
    # Control functions 

    def ctl_nl(self):
        """ Process the newline control character. """
        # if we're in a scrolling region, scroll instead of moving cursor down
        if self.lines != self.working_lines and self.l == self.bottom:
            del self.screen[self.top]
            self.screen.insert(self.bottom, '')
        elif self.l == self.bottom:
            self.screen.append('')
        else:
            self.l += 1

        self.color_changes = {}

    def ctl_cr(self):
        """ Process the carriage return control character. """
        self.c = 1

        self.color_changes = {}

    def ctl_bs(self):
        """ Process the backspace control character. """
        if self.c > 1:
            self.c += -1

    def ctl_soh(self):
        """ Process the start of heading control character. """
        pass

    def ctl_stx(self):
        pass

    def ctl_bel(self):
        """ Process the bell control character. """
        vim.command('call conque_term#bell()')

    def ctl_tab(self):
        """ Process the tab control character. """
        # default tabstop location
        ts = self.working_columns

        # check set tabstops
        for i in range(self.c, len(self.tabstops)):
            if self.tabstops[i]:
                ts = i + 1
                break



        self.c = ts

    def ctl_so(self):
        """ Process the shift out control character. """
        self.character_set = 'graphics'

    def ctl_si(self):
        """ Process the shift in control character. """
        self.character_set = 'ascii'



    ###############################################################################################
    # CSI functions 

    def csi_font(self, csi):
        """ Process the text attribute escape sequence. """
        if not self.enable_colors:
            return

        # defaults to 0
        if len(csi['vals']) == 0:
            csi['vals'] = [0]

        # 256 xterm color foreground
        if len(csi['vals']) == 3 and csi['vals'][0] == 38 and csi['vals'][1] == 5:
            self.color_changes['ctermfg'] = str(csi['vals'][2])
            self.color_changes['guifg'] = '#' + self.xterm_to_rgb(csi['vals'][2])

        # 256 xterm color background
        elif len(csi['vals']) == 3 and csi['vals'][0] == 48 and csi['vals'][1] == 5:
            self.color_changes['ctermbg'] = str(csi['vals'][2])
            self.color_changes['guibg'] = '#' + self.xterm_to_rgb(csi['vals'][2])

        # 16 colors
        else:
            for val in csi['vals']:
                if val in CONQUE_FONT:

                    # ignore starting normal colors
                    if CONQUE_FONT[val]['normal'] and len(self.color_changes) == 0:

                        continue
                    # clear color changes
                    elif CONQUE_FONT[val]['normal']:

                        self.color_changes = {}
                    # save these color attributes for next plain_text() call
                    else:

                        for attr in CONQUE_FONT[val]['attributes'].keys():
                            if attr in self.color_changes and (attr == 'cterm' or attr == 'gui'):
                                self.color_changes[attr] += ',' + CONQUE_FONT[val]['attributes'][attr]
                            else:
                                self.color_changes[attr] = CONQUE_FONT[val]['attributes'][attr]


    def csi_clear_line(self, csi):
        """ Process the line clear escape sequence. """


        # this escape defaults to 0
        if len(csi['vals']) == 0:
            csi['val'] = 0




        # 0 means cursor right
        if csi['val'] == 0:
            self.screen[self.l] = self.screen[self.l][0:self.c - 1]

        # 1 means cursor left
        elif csi['val'] == 1:
            self.screen[self.l] = ' ' * (self.c) + self.screen[self.l][self.c:]

        # clear entire line
        elif csi['val'] == 2:
            self.screen[self.l] = ''

        # clear colors
        if csi['val'] == 2 or (csi['val'] == 0 and self.c == 1):
            buffer_line = self.get_buffer_line(self.l)
            if buffer_line in self.color_history:
                for syn in self.color_history[buffer_line]:
                    vim.command('syn clear ' + syn['name'])





    def csi_cursor_right(self, csi):
        """ Process the move cursor right escape sequence. """
        # we use 1 even if escape explicitly specifies 0
        if csi['val'] == 0:
            csi['val'] = 1




        if self.wrap_cursor and self.c + csi['val'] > self.working_columns:
            self.l += int(math.floor((self.c + csi['val']) / self.working_columns))
            self.c = (self.c + csi['val']) % self.working_columns
            return

        self.c = self.bound(self.c + csi['val'], 1, self.working_columns)


    def csi_cursor_left(self, csi):
        """ Process the move cursor left escape sequence. """
        # we use 1 even if escape explicitly specifies 0
        if csi['val'] == 0:
            csi['val'] = 1

        if self.wrap_cursor and csi['val'] >= self.c:
            self.l += int(math.floor((self.c - csi['val']) / self.working_columns))
            self.c = self.working_columns - (csi['val'] - self.c) % self.working_columns
            return

        self.c = self.bound(self.c - csi['val'], 1, self.working_columns)


    def csi_cursor_to_column(self, csi):
        """ Process the move cursor to column escape sequence. """
        self.c = self.bound(csi['val'], 1, self.working_columns)


    def csi_cursor_up(self, csi):
        """ Process the move cursor up escape sequence. """
        self.l = self.bound(self.l - csi['val'], self.top, self.bottom)

        self.color_changes = {}


    def csi_cursor_down(self, csi):
        """ Process the move cursor down escape sequence. """
        self.l = self.bound(self.l + csi['val'], self.top, self.bottom)

        self.color_changes = {}


    def csi_clear_screen(self, csi):
        """ Process the clear screen escape sequence. """
        # default to 0
        if len(csi['vals']) == 0:
            csi['val'] = 0

        # 2 == clear entire screen
        if csi['val'] == 2:
            self.l = 1
            self.c = 1
            self.screen.clear()

        # 0 == clear down
        elif csi['val'] == 0:
            for l in range(self.bound(self.l + 1, 1, self.lines), self.lines + 1):
                self.screen[l] = ''

            # clear end of current line
            self.csi_clear_line(self.parse_csi('K'))

        # 1 == clear up
        elif csi['val'] == 1:
            for l in range(1, self.bound(self.l, 1, self.lines + 1)):
                self.screen[l] = ''

            # clear beginning of current line
            self.csi_clear_line(self.parse_csi('1K'))

        # clear coloration
        if csi['val'] == 2 or csi['val'] == 0:
            buffer_line = self.get_buffer_line(self.l)
            for line in self.color_history.keys():
                if line >= buffer_line:
                    for syn in self.color_history[line]:
                        vim.command('syn clear ' + syn['name'])

        self.color_changes = {}


    def csi_delete_chars(self, csi):
        self.screen[self.l] = self.screen[self.l][:self.c] + self.screen[self.l][self.c + csi['val']:]


    def csi_add_spaces(self, csi):
        self.screen[self.l] = self.screen[self.l][: self.c - 1] + ' ' * csi['val'] + self.screen[self.l][self.c:]


    def csi_cursor(self, csi):
        if len(csi['vals']) == 2:
            new_line = csi['vals'][0]
            new_col = csi['vals'][1]
        else:
            new_line = 1
            new_col = 1

        if self.absolute_coords:
            self.l = self.bound(new_line, 1, self.lines)
        else:
            self.l = self.bound(self.top + new_line - 1, self.top, self.bottom)

        self.c = self.bound(new_col, 1, self.working_columns)
        if self.c > len(self.screen[self.l]):
            self.screen[self.l] = self.screen[self.l] + ' ' * (self.c - len(self.screen[self.l]))



    def csi_set_coords(self, csi):
        if len(csi['vals']) == 2:
            new_start = csi['vals'][0]
            new_end = csi['vals'][1]
        else:
            new_start = 1
            new_end = vim.current.window.height

        self.top = new_start
        self.bottom = new_end
        self.working_lines = new_end - new_start + 1

        # if cursor is outside scrolling region, reset it
        if self.l < self.top:
            self.l = self.top
        elif self.l > self.bottom:
            self.l = self.bottom

        self.color_changes = {}


    def csi_tab_clear(self, csi):
        # this escape defaults to 0
        if len(csi['vals']) == 0:
            csi['val'] = 0



        if csi['val'] == 0:
            self.tabstops[self.c - 1] = False
        elif csi['val'] == 3:
            for i in range(0, self.columns + 1):
                self.tabstops[i] = False


    def csi_set(self, csi):
        # 132 cols
        if csi['val'] == 3:
            self.csi_clear_screen(self.parse_csi('2J'))
            self.working_columns = 132

        # relative_origin
        elif csi['val'] == 6:
            self.absolute_coords = False

        # set auto wrap
        elif csi['val'] == 7:
            self.autowrap = True


        self.color_changes = {}


    def csi_reset(self, csi):
        # 80 cols
        if csi['val'] == 3:
            self.csi_clear_screen(self.parse_csi('2J'))
            self.working_columns = 80

        # absolute origin
        elif csi['val'] == 6:
            self.absolute_coords = True

        # reset auto wrap
        elif csi['val'] == 7:
            self.autowrap = False


        self.color_changes = {}




    ###############################################################################################
    # ESC functions 

    def esc_scroll_up(self):
        self.ctl_nl()

        self.color_changes = {}


    def esc_next_line(self):
        self.ctl_nl()
        self.c = 1


    def esc_set_tab(self):

        if self.c <= len(self.tabstops):
            self.tabstops[self.c - 1] = True


    def esc_scroll_down(self):
        if self.l == self.top:
            del self.screen[self.bottom]
            self.screen.insert(self.top, '')
        else:
            self.l += -1

        self.color_changes = {}




    ###############################################################################################
    # HASH functions 

    def hash_screen_alignment_test(self):
        self.csi_clear_screen(self.parse_csi('2J'))
        self.working_lines = self.lines
        for l in range(1, self.lines + 1):
            self.screen[l] = 'E' * self.working_columns



    ###############################################################################################
    # CHARSET functions 

    def charset_us(self):
        self.character_set = 'ascii'

    def charset_uk(self):
        self.character_set = 'ascii'

    def charset_graphics(self):
        self.character_set = 'graphics'



    ###############################################################################################
    # Random stuff 

    def set_cursor(self, line, col):
        """ Set cursor position in the Vim buffer.

        Note: the line and column numbers are relative to the top left corner of the 
        visible screen. Not the line number in the Vim buffer.

        """
        self.screen.set_cursor(line, col)

    def change_title(self, key, val):
        """ Change the Vim window title. """


        if key == '0' or key == '2':

            vim.command('setlocal statusline=' + re.escape(val))
            try:
                vim.command('set titlestring=' + re.escape(val))
            except:
                pass

    def update_window_size(self, force=False):
        """ Check and save the current buffer dimensions.

        If the buffer size has changed, the update_window_size() method both updates
        the Conque buffer size attributes as well as sending the new dimensions to the
        subprocess pty.

        """
        # resize if needed
        if force or vim.current.window.width != self.columns or vim.current.window.height != self.lines:

            # reset all window size attributes to default
            self.columns = vim.current.window.width
            self.lines = vim.current.window.height
            self.working_columns = vim.current.window.width
            self.working_lines = vim.current.window.height
            self.bottom = vim.current.window.height

            # reset screen object attributes
            self.l = self.screen.reset_size(self.l)

            # reset tabstops
            self.init_tabstops()



            # signal process that screen size has changed
            self.proc.window_resize(self.lines, self.columns)

    def insert_enter(self):
        """ Run commands when user enters insert mode. """

        # check window size
        self.update_window_size()

        # we need to set the cursor position
        self.cursor_set = False

    def init_tabstops(self):
        """ Intitialize terminal tabstop positions. """
        for i in range(0, self.columns + 1):
            if i % 8 == 0:
                self.tabstops.append(True)
            else:
                self.tabstops.append(False)

    def idle(self):
        """ Called when this terminal becomes idle. """
        pass

    def resume(self):
        """ Called when this terminal is no longer idle. """
        pass
        pass

    def close(self):
        """ End the process running in the terminal. """
        self.proc.close()

    def abort(self):
        """ Forcefully end the process running in the terminal. """
        self.proc.signal(1)



    ###############################################################################################
    # Utility 

    def parse_csi(self, s):
        """ Parse an escape sequence into it's meaningful values. """

        attr = {'key': s[-1], 'flag': '', 'val': 1, 'vals': []}

        if len(s) == 1:
            return attr

        full = s[0:-1]

        if full[0] == '?':
            full = full[1:]
            attr['flag'] = '?'

        if full != '':
            vals = full.split(';')
            for val in vals:

                val = re.sub("\D", "", val)

                if val != '':
                    attr['vals'].append(int(val))

        if len(attr['vals']) == 1:
            attr['val'] = int(attr['vals'][0])

        return attr


    def bound(self, val, min, max):
        """ TODO: This probably exists as a builtin function. """
        if val > max:
            return max

        if val < min:
            return min

        return val


    def xterm_to_rgb(self, color_code):
        """ Translate a terminal color number into a RGB string. """
        if color_code < 16:
            ascii_colors = ['000000', 'CD0000', '00CD00', 'CDCD00', '0000EE', 'CD00CD', '00CDCD', 'E5E5E5',
                   '7F7F7F', 'FF0000', '00FF00', 'FFFF00', '5C5CFF', 'FF00FF', '00FFFF', 'FFFFFF']
            return ascii_colors[color_code]

        elif color_code < 232:
            cc = int(color_code) - 16

            p1 = "%02x" % (math.floor(cc / 36) * (255 / 5))
            p2 = "%02x" % (math.floor((cc % 36) / 6) * (255 / 5))
            p3 = "%02x" % (math.floor(cc % 6) * (255 / 5))

            return p1 + p2 + p3
        else:
            grey_tone = "%02x" % math.floor((255 / 24) * (color_code - 232))
            return grey_tone + grey_tone + grey_tone




    def get_buffer_line(self, line):
        """ Get the buffer line number corresponding to the supplied screen line number. """
        return self.screen.get_buffer_line(line)


