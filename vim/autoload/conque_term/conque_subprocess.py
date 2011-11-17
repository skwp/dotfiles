# FILE:     autoload/conque_term/conque_subprocess.py
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
ConqueSubprocess

Create and interact with a subprocess through a pty.

Usage:

    p = ConqueSubprocess()
    p.open('bash', {'TERM':'vt100'})
    output = p.read()
    p.write('cd ~/vim' + "\r")
    p.write('ls -lha' + "\r")
    output += p.read(timeout = 500)
    p.close()
"""

import os
import signal
import pty
import tty
import select
import fcntl
import termios
import struct
import shlex


class ConqueSubprocess:

    # process id
    pid = 0

    # stdout+stderr file descriptor
    fd = None


    def open(self, command, env={}):
        """ Create subprocess using forkpty() """

        # parse command
        command_arr = shlex.split(command)
        executable = command_arr[0]
        args = command_arr

        # try to fork a new pty
        try:
            self.pid, self.fd = pty.fork()

        except:

            return False

        # child proc, replace with command after altering terminal attributes
        if self.pid == 0:

            # set requested environment variables
            for k in env.keys():
                os.environ[k] = env[k]

            # set tty attributes
            try:
                attrs = tty.tcgetattr(1)
                attrs[0] = attrs[0] ^ tty.IGNBRK
                attrs[0] = attrs[0] | tty.BRKINT | tty.IXANY | tty.IMAXBEL
                attrs[2] = attrs[2] | tty.HUPCL
                attrs[3] = attrs[3] | tty.ICANON | tty.ECHO | tty.ISIG | tty.ECHOKE
                attrs[6][tty.VMIN] = 1
                attrs[6][tty.VTIME] = 0
                tty.tcsetattr(1, tty.TCSANOW, attrs)
            except:

                pass

            # replace this process with the subprocess
            os.execvp(executable, args)

        # else master, do nothing
        else:
            pass


    def read(self, timeout=1):
        """ Read from subprocess and return new output """

        output = ''
        read_timeout = float(timeout) / 1000
        read_ct = 0

        try:
            # read from fd until no more output
            while 1:
                s_read, s_write, s_error = select.select([self.fd], [], [], read_timeout)

                lines = ''
                for s_fd in s_read:
                    try:
                        # increase read buffer so huge reads don't slow down
                        if read_ct < 10:
                            lines = os.read(self.fd, 32)
                        elif read_ct < 50:
                            lines = os.read(self.fd, 512)
                        else:
                            lines = os.read(self.fd, 2048)
                        read_ct += 1
                    except:
                        pass
                    output = output + lines.decode('utf-8')

                if lines == '' or read_ct > 100:
                    break
        except:

            pass

        return output


    def write(self, input):
        """ Write new input to subprocess """

        try:
            if CONQUE_PYTHON_VERSION == 2:
                os.write(self.fd, input.encode('utf-8', 'ignore'))
            else:
                os.write(self.fd, bytes(input, 'utf-8'))
        except:

            pass


    def signal(self, signum):
        """ signal process """

        try:
            os.kill(self.pid, signum)
        except:
            pass


    def close(self):
        """ close process with sigterm signal """

        self.signal(15)


    def is_alive(self):
        """ get process status """

        p_status = True
        try:
            if os.waitpid(self.pid, os.WNOHANG)[0]:
                p_status = False
        except:
            p_status = False

        return p_status


    def window_resize(self, lines, columns):
        """ update window size in kernel, then send SIGWINCH to fg process """

        try:
            fcntl.ioctl(self.fd, termios.TIOCSWINSZ, struct.pack("HHHH", lines, columns, 0, 0))
            os.kill(self.pid, signal.SIGWINCH)
        except:
            pass


# vim:foldmethod=marker
