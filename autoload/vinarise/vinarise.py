import mmap
import os
import re
import vim
import os.path

class VinariseBuffer:
    def open(self, path, is_windows):
        # init vars
        self.file = open(path, 'rb')
        self.path = path
        self.is_windows = is_windows
        self.fsize = os.path.getsize(self.path)
        mmap_max = 0
        if self.fsize > 1000000000:
            mmap_max = 1000000000

        if int(is_windows):
            self.mmap = mmap.mmap(self.file.fileno(), mmap_max,
                    None, mmap.ACCESS_COPY, 0)
        else:
            self.mmap = mmap.mmap(self.file.fileno(), mmap_max,
                    access = mmap.ACCESS_COPY, offset = 0)

    def open_bytes(self, length, is_windows):
        # init vars
        self.path = ''
        self.is_windows = is_windows
        self.fsize = int(length)

        if int(is_windows):
            self.mmap = mmap.mmap(-1, self.fsize,
                    None, mmap.ACCESS_COPY, 0)
        else:
            self.mmap = mmap.mmap(-1, self.fsize,
                    access = mmap.ACCESS_COPY, offset = 0)

    def close(self):
        if hasattr(self, 'file'):
            self.file.close()
        self.mmap.close()

    def write(self, path):
        if path == self.path:
            # Close current file temporary.
            str = self.mmap[0:]
            is_windows = self.is_windows
            self.close()
        else:
            str = self.mmap

        write_file = open(path, 'wb')
        write_file.write(str)
        write_file.close()

        if path == self.path:
            # Re open file.
            self.open(path, is_windows)

    def get_byte(self, addr):
        return ord(self.mmap[int(addr)])

    def get_bytes(self, addr, count):
        if int(count) == 0:
            return []
        return [ord(x) for x in self.mmap[int(addr) : int(addr)+int(count)]]

    def get_int8(self, addr):
        return self.get_byte(addr)

    def get_int16_le(self, addr):
        bytes = self.get_bytes(addr, 2)
        return bytes[0] + bytes[1] * 0x100

    def get_int16_be(self, addr):
        bytes = self.get_bytes(addr, 2)
        return bytes[1] + bytes[0] * 0x100

    def get_int32_le(self, addr):
        bytes = self.get_bytes(addr, 4)
        return bytes[0] +  bytes[1] * 0x100 + bytes[2] * 0x10000 + bytes[3] * 0x1000000

    def get_int32_be(self, addr):
        bytes = self.get_bytes(addr, 4)
        return bytes[3] +  bytes[2] * 0x100 + bytes[1] * 0x10000 + bytes[0] * 0x1000000

    def get_chars(self, addr, count, from_enc, to_enc):
        if int(count) == 0:
            return ""
        chars = self.mmap[int(addr) : int(addr)+int(count)]
        return unicode(chars, from_enc, 'replace').encode(to_enc, 'replace')

    def set_byte(self, addr, value):
        self.mmap[int(addr)] = chr(int(value))

    def get_percentage(self, address):
        return (int(address)*100) / (self.fsize - 1)

    def get_percentage_address(self, percent):
        return ((self.fsize - 1) * int(percent)) / 100

    def find(self, address, str, from_enc, to_enc):
        pattern = unicode(str, from_enc, 'replace').encode(to_enc, 'replace')
        return self.mmap.find(pattern, int(address))

    def rfind(self, address, str, from_enc, to_enc):
        pattern = unicode(str, from_enc, 'replace').encode(to_enc, 'replace')
        return self.mmap.rfind(pattern, 0, int(address))

    def find_regexp(self, address, str, from_enc, to_enc):
        pattern = re.compile(unicode(str, from_enc, 'replace').encode(to_enc, 'replace'))
        m = pattern.search(self.mmap, int(address))
        if m is None:
            return -1
        else:
            return m.start()

    def find_binary(self, address, binary):
        addr = int(address)
        bytes = [int(binary[i*2 : i*2+2], 16) for i in range(len(binary) / 2)]
        while addr < self.fsize:
            if self.get_byte(addr) == bytes[0] and bytes == self.get_bytes(addr, len(bytes)):
                return addr
            addr += 1
        return -1

    def rfind_binary(self, address, binary):
        addr = int(address)
        bytes = [int(binary[i*2 : i*2+2], 16) for i in range(len(binary) / 2)]
        while addr < self.fsize:
            if self.get_byte(addr) == bytes[0] and bytes == self.get_bytes(addr, len(bytes)):
                return addr
            addr -= 1
        return -1

    def find_binary_not(self, address, binary):
        addr = int(address)
        bytes = [int(binary[i*2 : i*2+2], 16) for i in range(len(binary) / 2)]
        while addr < self.fsize:
            if self.get_byte(addr) != bytes[0] and bytes != self.get_bytes(addr, len(bytes)):
                return addr
            addr += 1
        return -1

    def rfind_binary_not(self, address, binary):
        addr = int(address)
        bytes = [int(binary[i*2 : i*2+2], 16) for i in range(len(binary) / 2)]
        while addr < self.fsize:
            if self.get_byte(addr) != bytes[0] and bytes != self.get_bytes(addr, len(bytes)):
                return addr
            addr -= 1
        return -1

