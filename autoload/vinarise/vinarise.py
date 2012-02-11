import mmap
import os
import vim

class VinariseBuffer:
    def open(self, path, is_windows):
        # init vars
        self.file = open(path, 'r+')
        if is_windows:
            self.mmap = mmap.mmap(self.file.fileno(), 0,
                    None, mmap.ACCESS_COPY, 0)
        else:
            self.mmap = mmap.mmap(self.file.fileno(), 0,
                    mmap.MAP_PRIVATE, mmap.PROT_READ | mmap.PROT_WRITE, mmap.ACCESS_COPY, 0)


    def get_byte(self, addr):
        return ord(self.mmap[int(addr)])

