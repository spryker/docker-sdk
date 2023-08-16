import os
import sys
import stackprinter

from project_manager.config import ProjectManagerConfig
from project_manager.factory import ProjectManagerFactory

if __name__ == '__main__':
    stackprinter.set_excepthook(style='darkbg2')

    config = ProjectManagerConfig(os.getcwd())
    factory = ProjectManagerFactory(config)
    args = factory.get_argument_builder().build(sys.argv[1:])

    factory\
        .get_application()\
        .run(args)
