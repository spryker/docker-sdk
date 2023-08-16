from typing import List
from docker_sdk.application.command_manager.command.command_interface import CommandInterface
from kernel.config_builder.config_builder import ConfigBuilder


class ConfigBuildCommand(CommandInterface):
    config_builders: List[ConfigBuilder]

    def __init__(self, config_builders: List[ConfigBuilder]):
        self.config_builders = config_builders

    def run(self, argv: list):

        for bash_config_builder in self.config_builders:
            bash_config_builder.build()

    def get_name(self) -> str:
        return 'config-build'
