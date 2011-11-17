# FILE:     autoload/conque_term/conque_sole_shared_memory.py
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
Wrapper class for shared memory between Windows python processes

Adds a small amount of functionality to the standard mmap module.

"""

import mmap
import sys

# PYTHON VERSION
CONQUE_PYTHON_VERSION = sys.version_info[0]

if CONQUE_PYTHON_VERSION == 2:
    import cPickle as pickle
else:
    import pickle


class ConqueSoleSharedMemory():

    # is the data being stored not fixed length
    fixed_length = False

    # maximum number of bytes per character, for fixed width blocks
    char_width = 1

    # fill memory with this character when clearing and fixed_length is true
    FILL_CHAR = None

    # serialize and unserialize data automatically
    serialize = False

    # size of shared memory, in bytes / chars
    mem_size = None

    # size of shared memory, in bytes / chars
    mem_type = None

    # unique key, so multiple console instances are possible
    mem_key = None

    # mmap instance
    shm = None

    # character encoding, dammit
    encoding = 'utf-8'

    # pickle terminator
    TERMINATOR = None


    def __init__(self, mem_size, mem_type, mem_key, fixed_length=False, fill_char=' ', serialize=False, encoding='utf-8'):
        """ Initialize new shared memory block instance

        Arguments:
        mem_size -- Memory size in characters, depends on encoding argument to calcuate byte size
        mem_type -- Label to identify what will be stored
        mem_key -- Unique, probably random key to identify this block
        fixed_length -- If set to true, assume the data stored will always fill the memory size
        fill_char -- Initialize memory block with this character, only really helpful with fixed_length blocks
        serialize -- Automatically serialize data passed to write. Allows storing non-byte data
        encoding -- Character encoding to use when storing character data

        """
        self.mem_size = mem_size
        self.mem_type = mem_type
        self.mem_key = mem_key
        self.fixed_length = fixed_length
        self.fill_char = fill_char
        self.serialize = serialize
        self.encoding = encoding
        self.TERMINATOR = str(chr(0)).encode(self.encoding)

        if CONQUE_PYTHON_VERSION == 3:
            self.FILL_CHAR = fill_char
        else:
            self.FILL_CHAR = unicode(fill_char)

        if fixed_length and encoding == 'utf-8':
            self.char_width = 4


    def create(self, access='write'):
        """ Create a new block of shared memory using the mmap module. """

        if access == 'write':
            mmap_access = mmap.ACCESS_WRITE
        else:
            mmap_access = mmap.ACCESS_READ

        name = "conque_%s_%s" % (self.mem_type, self.mem_key)

        self.shm = mmap.mmap(0, self.mem_size * self.char_width, name, mmap_access)

        if not self.shm:
            return False
        else:
            return True


    def read(self, chars=1, start=0):
        """ Read data from shared memory.

        If this is a fixed length block, read 'chars' characters from memory. 
        Otherwise read up until the TERMINATOR character (null byte).
        If this memory is serialized, unserialize it automatically.

        """
        # go to start position
        self.shm.seek(start * self.char_width)

        if self.fixed_length:
            chars = chars * self.char_width
        else:
            chars = self.shm.find(self.TERMINATOR)

        if chars == 0:
            return ''

        shm_str = self.shm.read(chars)

        # return unpickled byte object
        if self.serialize:
            return pickle.loads(shm_str)

        # decode byes in python 3
        if CONQUE_PYTHON_VERSION == 3:
            return str(shm_str, self.encoding)

        # encoding
        if self.encoding != 'ascii':
            shm_str = unicode(shm_str, self.encoding)

        return shm_str


    def write(self, text, start=0):
        """ Write data to memory.

        If memory is fixed length, simply write the 'text' characters at 'start' position.
        Otherwise write 'text' characters and append a null character.
        If memory is serializable, do so first.

        """
        # simple scenario, let pickle create bytes
        if self.serialize:
            if CONQUE_PYTHON_VERSION == 3:
                tb = pickle.dumps(text, 0)
            else:
                tb = pickle.dumps(text, 0).encode(self.encoding)

        else:
            tb = text.encode(self.encoding, 'replace')

        # write to memory
        self.shm.seek(start * self.char_width)

        if self.fixed_length:
            self.shm.write(tb)
        else:
            self.shm.write(tb + self.TERMINATOR)


    def clear(self, start=0):
        """ Clear memory block using self.fill_char. """

        self.shm.seek(start)

        if self.fixed_length:
            self.shm.write(str(self.fill_char * self.mem_size * self.char_width).encode(self.encoding))
        else:
            self.shm.write(self.TERMINATOR)


    def close(self):
        """ Close/destroy memory block. """

        self.shm.close()


