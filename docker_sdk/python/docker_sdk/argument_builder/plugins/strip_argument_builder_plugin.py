from docker_sdk.argument_builder.plugins.argument_builder_plugin_interface import ArgumentBuilderPluginInterface


class StripArgumentBuilderPlugin(ArgumentBuilderPluginInterface):
    def build(self, argument_list: list) -> list:
        return [argument.strip('') for argument in argument_list]
