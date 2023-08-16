from jinja2 import Environment, FileSystemLoader

from kernel.command.config_build_command import ConfigBuildCommand
from kernel.command.init_sdk_db_command import InitSdkDbCommand
from kernel.command.modules_load_command import ModulesLoadCommand
from kernel.config import KernelConfig
from kernel.config_builder.bash.formatter.bash_config_formatter import BashConfigFormatter
from kernel.config_builder.bash.formatter.formatters.key.prefix_key_formatter import PrefixKeyFormatter
from kernel.config_builder.bash.formatter.formatters.key.snake_case_formatter import SnakeCaseFormatter
from kernel.config_builder.bash.formatter.formatters.value.bool_formatter import BoolFormatter
from kernel.config_builder.bash.formatter.formatters.value.list_formatter import ListFormatter
from kernel.config_builder.bash.render.bash_config_render import BashConfigRender
from kernel.config_builder.config_builder import ConfigBuilder
from kernel.config_builder.config_formatter_interface import ConfigFormatterInterface
from kernel.config_builder.yml.formatter.yml_config_formatter import YmlConfigFormatter
from kernel.config_builder.yml.render.yml_config_render import YmlConfigRender
from kernel.sdk_db.db_creator.db_creator import DbCreator
from kernel.sdk_modules.builder.module_builder import ModuleBuilder
from docker_sdk.factory.abstract_application_factory import AbstractApplicationFactory
from docker_sdk.factory.db_factory import DbFactory


class KernelFactory(DbFactory, AbstractApplicationFactory):
    config: KernelConfig

    def get_application_command_class_list(self) -> list:
        return [
            InitSdkDbCommand(self.get_db_creator()),
            ConfigBuildCommand([
                self.get_bash_config_builder(),
                self.get_yml_config_builder(),
            ]),
            ModulesLoadCommand(self.get_module_builder()),
        ]

    def get_jinja(self) -> Environment:
        return Environment(
            loader=FileSystemLoader(
                searchpath=self.config.get_templates_directory_path()
            )
        )

    def get_bash_config_formatter(self) -> ConfigFormatterInterface:
        return BashConfigFormatter(
            self.get_bash_value_formatter_list(),
            self.get_bash_key_formatter_list(),
        )

    def get_bash_value_formatter_list(self) -> list:
        return [
            BoolFormatter(),
            ListFormatter(),
        ]

    def get_bash_key_formatter_list(self) -> list:
        return [
            SnakeCaseFormatter(),
            PrefixKeyFormatter(),
        ]

    def get_module_builder(self) -> ModuleBuilder:
        return ModuleBuilder(
            jinja=self.get_jinja(),
            config=self.config,
        )

    def get_bash_config_builder(self):
        return ConfigBuilder(
            config_formatter=self.get_bash_config_formatter(),
            config=self.config,
            render=self.get_bash_config_render(),
        )

    def get_db_creator(self) -> DbCreator:
        return DbCreator(
            self.config,
        )

    def get_bash_config_render(self):
        return BashConfigRender(
            config=self.config,
            jinja=self.get_jinja(),
        )

    def get_yml_config_builder(self):
        return ConfigBuilder(
            config_formatter=self.get_yml_config_formatter(),
            config=self.config,
            render=self.get_yml_config_render(),
        )

    def get_yml_config_formatter(self) -> ConfigFormatterInterface:
        return YmlConfigFormatter()

    def get_yml_config_render(self):
        return YmlConfigRender(
            config=self.config,
            jinja=self.get_jinja(),
        )
