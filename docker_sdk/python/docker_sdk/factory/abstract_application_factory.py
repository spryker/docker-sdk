import abc

from typing import List
from docker_sdk.application.Application import Application
from docker_sdk.application.command_manager.command.command_interface import CommandInterface
from docker_sdk.application.command_manager.command_manager import CommandManager
from docker_sdk.argument_builder.argument_builder import ArgumentBuilder
from docker_sdk.argument_builder.plugins.argument_builder_plugin_interface import ArgumentBuilderPluginInterface
from docker_sdk.argument_builder.plugins.empty_string_builder_plugin import EmptyStringBuilderPlugin
from docker_sdk.argument_builder.plugins.strip_argument_builder_plugin import StripArgumentBuilderPlugin
from docker_sdk.table_formatter.TableFormatter import TableFormatter


class AbstractApplicationFactory(abc.ABC):
    def get_application(self) -> Application:
        return Application(self.get_command_manager())

    def get_command_manager(self) -> CommandManager:
        return CommandManager(self.get_application_command_class_list())

    def get_argument_builder(self) -> ArgumentBuilder:
        return ArgumentBuilder(
            self.get_argument_builder_plugin_list()
        )

    def get_argument_builder_plugin_list(self) -> List[ArgumentBuilderPluginInterface]:
        return [
            StripArgumentBuilderPlugin(),
            EmptyStringBuilderPlugin(),
        ]

    def get_table_formatter(self) -> TableFormatter:
        return TableFormatter()

    @abc.abstractmethod
    def get_application_command_class_list(self) -> List[CommandInterface]:
        pass
