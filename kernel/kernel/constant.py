from docker_sdk.constant import Constant


class KernelConstant(Constant):
    BASH_MODULES_FILE_NAME = 'modules.sh'
    KERNEL_DIRECTORY_NAME = 'kernel'
    TEMPLATES_DIRECTORY_NAME = 'templates'
    CONFIG_BASH_KEY_SEPARATOR = '__'
    CONFIG_BASH_KEY_PREFIX = 'DOCKER_SDK'
    BASH_CONFIG_FILE_NAME = 'config.sh'
    YML_CONFIG_FILE_NAME = 'config.yml'
    MODULE_ENTRYPOINT_FILE_NAME = 'entrypoint.sh'
    CONFIG_MODULE_PATH_KEY = 'path'

    SDK_BASH_CONFIG_TEMPLATE_FILENAME = 'sdk_config.sh.jinja2'
    SDK_YML_CONFIG_TEMPLATE_FILENAME = 'sdk_config.yml.jinja2'
