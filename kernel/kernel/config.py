import os

from docker_sdk.config.abstract_config import AbstractConfig
from kernel.constant import KernelConstant


class KernelConfig(AbstractConfig):
    def get_kernel_module_path(self) -> str:
        return os.path.join(
            self.get_root_application_path(),
            KernelConstant.KERNEL_DIRECTORY_NAME,
            KernelConstant.KERNEL_DIRECTORY_NAME,
        )

    def get_templates_directory_path(self) -> str:
        return os.path.join(
            self.get_kernel_module_path(),
            KernelConstant.DATA_DIRECTORY_NAME,
            KernelConstant.TEMPLATES_DIRECTORY_NAME
        )

    def get_config_bash_file_path(self) -> str:
        return os.path.join(
            self.get_root_application_path(),
            KernelConstant.DATA_DIRECTORY_NAME,
            KernelConstant.BASH_CONFIG_FILE_NAME
        )

    def get_config_yml_file_path(self) -> str:
        return os.path.join(
            self.get_root_application_path(),
            KernelConstant.DATA_DIRECTORY_NAME,
            KernelConstant.YML_CONFIG_FILE_NAME
        )

    def get_modules_bash_file_path(self) -> str:
        return os.path.join(
            self.get_root_application_path(),
            KernelConstant.DATA_DIRECTORY_NAME,
            KernelConstant.BASH_MODULES_FILE_NAME
        )

    def get_sdk_bash_config_template_file_name(self) -> str:
        return KernelConstant.SDK_BASH_CONFIG_TEMPLATE_FILENAME

    def get_sdk_yml_config_template_file_name(self) -> str:
        return KernelConstant.SDK_YML_CONFIG_TEMPLATE_FILENAME
