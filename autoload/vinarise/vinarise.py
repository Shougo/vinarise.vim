# pylint: disable=missing-docstring
import mmap
import os
import re
import sys

import vim  # NOQA pylint: disable=import-error,unused-import

WINDOWS = sys.platform == 'win32'
PY3 = sys.version_info[0] == 3

if PY3:
    def ord_wrap(obj):
        ''' mmap[i] returns int '''
        return obj

    def chr_wrap(obj):
        ''' mmap[i] must be int '''
        return obj
else:
    def ord_wrap(obj):
        ''' mmap[i] returns int '''
        return ord(obj)

    def chr_wrap(obj):
        ''' mmap[i] must be int '''
        return chr(obj)


class VinariseBuffer(object):  # pylint: disable=too-many-public-methods
    def __init__(self):
        self.file = None
        self.path = None
        self.fsize = None
        self.mmap = None
        self.is_mmap = False

    def open(self, path):
        # init vars
        self.file = open(path, 'rb')
        self.path = path
        self.fsize = os.path.getsize(self.path)
        mmap_max = 0
        if self.fsize > 1000000000:
            mmap_max = 1000000000
        self._mmap(self.file.fileno(), mmap_max)

    def open_bytes(self, length):
        # init vars
        self.path = ''
        self.fsize = int(length)
        self._mmap(-1, self.fsize)

    def _mmap(self, fno, size):
        if WINDOWS:
            self.mmap = mmap.mmap(fno, size, None, mmap.ACCESS_COPY, 0)
        else:
            self.mmap = mmap.mmap(fno, size, access=mmap.ACCESS_COPY, offset=0)
        self.is_mmap = True

    def close(self):
        if hasattr(self, 'file'):
            self.file.close()
        if self.is_mmap:
            self.mmap.close()

    def write(self, path):
        if path == self.path:
            # Close current file temporary.
            string = self.mmap[0:]
            self.close()
        else:
            string = self.mmap

        write_file = open(path, 'wb')
        write_file.write(string)
        write_file.close()

        if path == self.path:
            # Re open file.
            self.open(path)

    def get_byte(self, addr):
        return ord_wrap(self.mmap[int(addr)])

    def get_bytes(self, addr, count):
        if int(count) == 0:
            return []
        return [ord_wrap(x) for x
                in self.mmap[int(addr): int(addr)+int(count)]]

    def get_int8(self, addr):
        return self.get_byte(addr)

    def get_int16_le(self, addr):
        bytesobj = self.get_bytes(addr, 2)
        return bytesobj[0] + bytesobj[1] * 0x100

    def get_int16_be(self, addr):
        bytesobj = self.get_bytes(addr, 2)
        return bytesobj[1] + bytesobj[0] * 0x100

    def get_int32_le(self, addr):
        bytesobj = self.get_bytes(addr, 4)
        return (bytesobj[0] + bytesobj[1] * 0x100
                + bytesobj[2] * 0x10000 + bytesobj[3] * 0x1000000)

    def get_int32_be(self, addr):
        bytesobj = self.get_bytes(addr, 4)
        return (bytesobj[3] + bytesobj[2] * 0x100
                + bytesobj[1] * 0x10000 + bytesobj[0] * 0x1000000)

    def get_chars(self, addr, count, from_enc, to_enc):
        if int(count) == 0:
            return ""
        chars = self.mmap[int(addr): int(addr)+int(count)]
        if not PY3:
            string = unicode(chars, from_enc, 'replace')
        return string.encode(to_enc, 'replace')

    def set_byte(self, addr, value):
        self.mmap[int(addr)] = chr_wrap(int(value))

    def get_percentage(self, address):
        return (int(address)*100) // (self.fsize - 1)

    def get_percentage_address(self, percent):
        return ((self.fsize - 1) * int(percent)) // 100

    def find(self, address, string, from_enc, to_enc):
        if not PY3:
            string = unicode(string, from_enc, 'replace')
        return self.mmap.find(string.encode(to_enc, 'replace'), int(address))

    def rfind(self, address, string, from_enc, to_enc):
        if not PY3:
            string = unicode(string, from_enc, 'replace')
        return self.mmap.rfind(string.encode(
            to_enc, 'replace'), 0, int(address))

    def find_regexp(self, address, string, from_enc, to_enc):
        if not PY3:
            string = unicode(string, from_enc, 'replace')
        pattern = re.compile(string.encode(to_enc, 'replace'))
        match = pattern.search(self.mmap, int(address))
        if match is None:
            return -1
        else:
            return match.start()

    def find_binary(self, address, binary):
        addr = int(address)
        bytesobj = [int(binary[i*2: i*2+2], 16)
                    for i in range(len(binary) // 2)]
        while addr >= 0 and addr < self.fsize:
            if self.get_byte(addr) == bytesobj[0] and \
                    bytesobj == self.get_bytes(addr, len(bytesobj)):
                return addr
            addr += 1
        return -1

    def rfind_binary(self, address, binary):
        addr = int(address)
        bytesobj = [int(binary[i*2: i*2+2], 16)
                    for i in range(len(binary) // 2)]
        while addr >= 0 and addr < self.fsize:
            if self.get_byte(addr) == bytesobj[0] and \
                    bytesobj == self.get_bytes(addr, len(bytesobj)):
                return addr
            addr -= 1
        return -1

    def find_binary_not(self, address, binary):
        addr = int(address)
        bytesobj = [int(binary[i*2: i*2+2], 16)
                    for i in range(len(binary) // 2)]
        while addr >= 0 and addr < self.fsize:
            if self.get_byte(addr) != bytesobj[0] and \
                    bytesobj != self.get_bytes(addr, len(bytesobj)):
                return addr
            addr += 1
        return -1

    def rfind_binary_not(self, address, binary):
        addr = int(address)
        bytesobj = [int(binary[i*2: i*2+2], 16)
                    for i in range(len(binary) // 2)]
        while addr >= 0 and addr < self.fsize:
            if self.get_byte(addr) != bytesobj[0] and \
                    bytesobj != self.get_bytes(addr, len(bytesobj)):
                return addr
            addr -= 1
        return -1

    def update_bytes(self, bs):
        if self.is_mmap:
            self.mmap.close()
        self.mmap = bs

        self.fsize = len(self.mmap)
        # Disable mmap
        self.is_mmap = False

    def insert_bytes(self, addr, bs):
        bs = bytes([chr_wrap(int(x)) for x in bs])
        mm = self.mmap[0:]
        self.update_bytes(mm[:int(addr)] + bs + mm[int(addr):])

    def delete_byte(self, addr):
        mm = self.mmap[0:]
        self.update_bytes(mm[:int(addr)] + mm[int(addr)+1:])
