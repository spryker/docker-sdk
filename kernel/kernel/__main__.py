import os
import sys
import stackprinter

from kernel.config import KernelConfig
from kernel.factory import KernelFactory

if __name__ == '__main__':
    stackprinter.set_excepthook(style='darkbg2')

    root_path = os.getcwd()
    config = KernelConfig(root_path)
    factory = KernelFactory(config)

    factory.get_application().run(sys.argv[1:])
