import mmap
import os
import vim

class VinariseBuffer:
    def __init__(self, path):
        # init vars
        self.file = open(path, 'r+')
        self.mmap = mmap.mmap(self.file.fileno(), 0)

    def get_byte(self, addr):
        return ord(self.mmap[int(addr)])

