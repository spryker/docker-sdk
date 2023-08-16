from typing import List
from docker_sdk.argument_builder.plugins.argument_builder_plugin_interface import ArgumentBuilderPluginInterface


class ArgumentBuilder:
    def __init__(self, argument_plugins: List[ArgumentBuilderPluginInterface]):
        self.__argument_plugins = argument_plugins

    def build(self, argument_list: list) -> list:
        for argument_plugin in self.__argument_plugins:
            argument_list = argument_plugin.build(argument_list)

        return argument_list
