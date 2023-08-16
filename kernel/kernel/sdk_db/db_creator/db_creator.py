import logging
import os

from kernel.config import KernelConfig


class DbCreator:
    config: KernelConfig

    def __init__(self, config: KernelConfig):
        self.config = config

    def create(self) -> None:
        db_path = self.config.get_db_path()

        if not os.path.exists(db_path):
            with open(db_path, 'w') as f:
                f.write('')
