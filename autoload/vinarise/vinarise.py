import mmap
import os
import vim
import os.path

class VinariseBuffer:
    def open(self, path, is_windows):
        # init vars
        self.file = open(path, 'r+')
        mmap_max = 0

        if is_windows:
            self.mmap = mmap.mmap(self.file.fileno(), mmap_max,
                    None, mmap.ACCESS_COPY, 0)
        else:
            self.mmap = mmap.mmap(self.file.fileno(), mmap_max,
                    mmap.MAP_PRIVATE, mmap.PROT_READ | mmap.PROT_WRITE, mmap.ACCESS_COPY, 0)
    def close(self):
        self.file.close()
        self.mmap.close()

    def get_byte(self, addr):
        return ord(self.mmap[int(addr)])

