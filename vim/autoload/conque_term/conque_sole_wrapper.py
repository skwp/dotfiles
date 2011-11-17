# FILE:     autoload/conque_term/conque_sole_wrapper.py 
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

ConqueSoleSubprocessWrapper

Subprocess wrapper to deal with Windows insanity. Launches console based python,
which in turn launches originally requested command. Communicates with cosole
python through shared memory objects.

"""

import ctypes
import time


class ConqueSoleWrapper():

    # unique key used for shared memory block names
    shm_key = ''

    # process info
    handle = None
    pid = None

    # queue input in this bucket
    bucket = None

    # console size
    lines = 24
    columns = 80

    # shared memory objects
    shm_input = None
    shm_output = None
    shm_attributes = None
    shm_stats = None
    shm_command = None
    shm_rescroll = None
    shm_resize = None

    # console python process
    proc = None


    def open(self, cmd, lines, columns, python_exe='python.exe', communicator_py='conque_sole_communicator.py', options={}):
        """ Launch python.exe subprocess which will in turn launch the user's program.

        Arguments:
        cmd -- The user's command to run. E.g. "Powershell.exe" or "C:\Python27\Scripts\ipython.bat"
        lines, columns -- The size of the console, also the size of the Vim buffer
        python.exe -- The path to the python executable, typically C:\PythonXX\python.exe
        communicator_py -- The path to the subprocess controller script in the user's vimfiles directory
        options -- optional configuration

        """
        self.lines = lines
        self.columns = columns
        self.bucket = u('')

        # create a shm key
        self.shm_key = 'mk' + str(time.time())

        # python command
        cmd_line = '%s "%s" %s %d %d %d %d %s' % (python_exe, communicator_py, self.shm_key, int(self.columns), int(self.lines), int(options['CODE_PAGE']), int(CONQUE_FAST_MODE), cmd)


        # console window attributes
        flags = NORMAL_PRIORITY_CLASS | DETACHED_PROCESS | CREATE_UNICODE_ENVIRONMENT
        si = STARTUPINFO()
        pi = PROCESS_INFORMATION()

        # start the stupid process already
        try:
            res = ctypes.windll.kernel32.CreateProcessW(None, u(cmd_line), None, None, 0, flags, None, u('.'), ctypes.byref(si), ctypes.byref(pi))
        except:

            raise

        # handle
        self.pid = pi.dwProcessId



        # init shared memory objects
        self.init_shared_memory(self.shm_key)


    def read(self, start_line, num_lines, timeout=0):
        """ Read a range of console lines from shared memory. 

        Returns a pair of lists containing the console text and console text attributes.

        """
        # emulate timeout by sleeping timeout time
        if timeout > 0:
            read_timeout = float(timeout) / 1000

            time.sleep(read_timeout)

        output = []
        attributes = []

        # get output
        for i in range(start_line, start_line + num_lines + 1):
            output.append(self.shm_output.read(self.columns, i * self.columns))
            if not CONQUE_FAST_MODE:
                attributes.append(self.shm_attributes.read(self.columns, i * self.columns))

        return (output, attributes)


    def get_stats(self):
        """ Return a dictionary with current console cursor and scrolling information. """

        try:
            rescroll = self.shm_rescroll.read()
            if rescroll != '' and rescroll != None:



                self.shm_rescroll.clear()

                # close down old memory
                self.shm_output.close()
                self.shm_output = None

                if not CONQUE_FAST_MODE:
                    self.shm_attributes.close()
                    self.shm_attributes = None

                # reallocate memory

                self.shm_output = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns * rescroll['data']['blocks'], 'output', rescroll['data']['mem_key'], True)
                self.shm_output.create('read')

                if not CONQUE_FAST_MODE:
                    self.shm_attributes = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns * rescroll['data']['blocks'], 'attributes', rescroll['data']['mem_key'], True, encoding='latin-1')
                    self.shm_attributes.create('read')

            stats_str = self.shm_stats.read()
            if stats_str != '':
                self.stats = stats_str
            else:
                return False
        except:

            return False

        return self.stats


    def is_alive(self):
        """ Get process status. """

        if not self.shm_stats:
            return True

        stats_str = self.shm_stats.read()
        if stats_str:
            return (stats_str['is_alive'])
        else:
            return True


    def write(self, text):
        """ Write input to shared memory. """

        self.bucket += text

        istr = self.shm_input.read()

        if istr == '':

            self.shm_input.write(self.bucket[:500])
            self.bucket = self.bucket[500:]


    def write_vk(self, vk_code):
        """ Write virtual key code to shared memory using proprietary escape sequences. """

        seq = u("\x1b[") + u(str(vk_code)) + u("VK")
        self.write(seq)


    def idle(self):
        """ Write idle command to shared memory block, so subprocess controller can hibernate. """


        self.shm_command.write({'cmd': 'idle', 'data': {}})


    def resume(self):
        """ Write resume command to shared memory block, so subprocess controller can wake up. """

        self.shm_command.write({'cmd': 'resume', 'data': {}})


    def close(self):
        """ Shut it all down. """

        self.shm_command.write({'cmd': 'close', 'data': {}})
        time.sleep(0.2)


    def window_resize(self, lines, columns):
        """ Resize console window. """

        self.lines = lines

        # we don't shrink buffer width
        if columns > self.columns:
            self.columns = columns

        self.shm_resize.write({'cmd': 'resize', 'data': {'width': columns, 'height': lines}})


    def init_shared_memory(self, mem_key):
        """ Create shared memory objects. """

        self.shm_input = ConqueSoleSharedMemory(CONQUE_SOLE_INPUT_SIZE, 'input', mem_key)
        self.shm_input.create('write')
        self.shm_input.clear()

        self.shm_output = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns, 'output', mem_key, True)
        self.shm_output.create('write')

        if not CONQUE_FAST_MODE:
            self.shm_attributes = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns, 'attributes', mem_key, True, encoding='latin-1')
            self.shm_attributes.create('write')

        self.shm_stats = ConqueSoleSharedMemory(CONQUE_SOLE_STATS_SIZE, 'stats', mem_key, serialize=True)
        self.shm_stats.create('write')
        self.shm_stats.clear()

        self.shm_command = ConqueSoleSharedMemory(CONQUE_SOLE_COMMANDS_SIZE, 'command', mem_key, serialize=True)
        self.shm_command.create('write')
        self.shm_command.clear()

        self.shm_resize = ConqueSoleSharedMemory(CONQUE_SOLE_RESIZE_SIZE, 'resize', mem_key, serialize=True)
        self.shm_resize.create('write')
        self.shm_resize.clear()

        self.shm_rescroll = ConqueSoleSharedMemory(CONQUE_SOLE_RESCROLL_SIZE, 'rescroll', mem_key, serialize=True)
        self.shm_rescroll.create('write')
        self.shm_rescroll.clear()

        return True


# vim:foldmethod=marker
