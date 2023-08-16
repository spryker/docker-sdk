import logging
import os

from jinja2 import Environment

from kernel.config import KernelConfig
from kernel.constant import KernelConstant


class ModuleBuilder:
    def __init__(
        self,
        config: KernelConfig,
        jinja: Environment
    ):
        self.jinja = jinja
        self.config = config

    def build(self):
        modules_import = []
        modules_import = self.__load_modules(modules_import)

        self.jinja.get_template('modules.sh.jinja2').stream({
            'modules_import': modules_import
        }).dump(self.config.get_modules_bash_file_path())

    def __load_modules(self, modules_import: list) -> list:
        modules_config = self.config.get_modules_config()

        for module_name, module_config in modules_config.items():
            entrypoint_path = self.get_entrypoint_path(
                os.path.join(
                    self.config.get_modules_directory_path(),
                    module_config[KernelConstant.CONFIG_MODULE_PATH_KEY]
                )
            )

            if not os.path.exists(entrypoint_path):
                raise Exception('Entrypoint not found: ' + entrypoint_path + ' for module: ' + module_name)

            entrypoint_path = os.path.join(
                '${MODULES_DIR}',
                module_config[KernelConstant.CONFIG_MODULE_PATH_KEY],
                KernelConstant.MODULE_ENTRYPOINT_FILE_NAME,
            )

            modules_import.append(entrypoint_path)

        return modules_import

    def get_entrypoint_path(self, module_path: str) -> str:
        return os.path.join(
            module_path,
            KernelConstant.MODULE_ENTRYPOINT_FILE_NAME
        )

    def __validate_module(self, module, module_entrypoint_path):
        pass



