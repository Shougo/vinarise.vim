import mmap
import os
import vim
import os.path

class VinariseBuffer:
    def open(self, path, is_windows):
        # init vars
        self.file = open(path, 'rb')
        self.path = path
        self.is_windows = is_windows
        fsize = os.path.getsize(self.path)
        mmap_max = 0
        if fsize > 1000000000:
            mmap_max = 1000000000

        if int(is_windows):
            self.mmap = mmap.mmap(self.file.fileno(), mmap_max,
                    None, mmap.ACCESS_COPY, 0)
        else:
            self.mmap = mmap.mmap(self.file.fileno(), mmap_max,
                    access = mmap.ACCESS_COPY, offset = 0)

    def close(self):
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

    def set_byte(self, addr, value):
        self.mmap[int(addr)] = chr(int(value))

    def get_percentage(self, address):
        return (int(address)*100) / os.path.getsize(self.path)

    def get_percentage_address(self, percent):
        return (os.path.getsize(self.path) * int(percent)) / 100

