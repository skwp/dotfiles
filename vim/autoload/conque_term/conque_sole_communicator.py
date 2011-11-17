# FILE:     autoload/conque_term/conque_sole_communicator.py
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

ConqueSoleCommunicator

This script will create a new Windows console and start the requested program 
inside of it. This process is launched independently from the parent Vim
program, so it has no access to the vim module.

The main loop in this script reads data from the console and syncs it onto 
blocks of memory shared with the Vim process. In this way the Vim process
and this script can communicate with each other.

"""

import time
import sys

from conque_globals import *
from conque_win32_util import *
from conque_sole_subprocess import *
from conque_sole_shared_memory import *

##############################################################
# only run if this file was run directly

if __name__ == '__main__':

    # attempt to catch ALL exceptions to fend of zombies
    try:

        # simple arg validation

        if len(sys.argv) < 5:

            exit()

        # maximum time this thing reads. 0 means no limit. Only for testing.
        max_loops = 0

        # read interval, in seconds
        sleep_time = 0.01

        # idle read interval, in seconds
        idle_sleep_time = 0.10

        # are we idled?
        is_idle = False

        # mem key
        mem_key = sys.argv[1]

        # console width
        console_width = int(sys.argv[2])

        # console height
        console_height = int(sys.argv[3])

        # code page
        code_page = int(sys.argv[4])

        # code page
        fast_mode = int(sys.argv[5])

        # the actual subprocess to run
        cmd_line = " ".join(sys.argv[6:])


        # width and height
        options = {'LINES': console_height, 'COLUMNS': console_width, 'CODE_PAGE': code_page, 'FAST_MODE': fast_mode}



        # set initial idle status
        shm_command = ConqueSoleSharedMemory(CONQUE_SOLE_COMMANDS_SIZE, 'command', mem_key, serialize=True)
        shm_command.create('write')

        cmd = shm_command.read()
        if cmd:

            if cmd['cmd'] == 'idle':
                is_idle = True
                shm_command.clear()


        ##############################################################
        # Create the subprocess

        proc = ConqueSoleSubprocess()
        res = proc.open(cmd_line, mem_key, options)

        if not res:

            exit()

        ##############################################################
        # main loop!

        loops = 0

        while True:

            # check for idle/resume
            if is_idle or loops % 25 == 0:

                # check process health
                if not proc.is_alive():

                    proc.close()
                    break

                # check for change in buffer focus
                cmd = shm_command.read()
                if cmd:

                    if cmd['cmd'] == 'idle':
                        is_idle = True
                        shm_command.clear()

                    elif cmd['cmd'] == 'resume':
                        is_idle = False
                        shm_command.clear()


            # sleep between loops if moderation is requested
            if sleep_time > 0:
                if is_idle:
                    time.sleep(idle_sleep_time)
                else:
                    time.sleep(sleep_time)

            # write, read, etc
            proc.write()
            proc.read()

            # increment loops, and exit if max has been reached
            loops += 1
            if max_loops and loops >= max_loops:

                break

        ##############################################################
        # all done!



        proc.close()

    # if an exception was thrown, croak
    except:

        proc.close()


# vim:foldmethod=marker
