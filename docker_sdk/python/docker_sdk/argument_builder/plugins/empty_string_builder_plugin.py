from docker_sdk.argument_builder.plugins.argument_builder_plugin_interface import ArgumentBuilderPluginInterface


class EmptyStringBuilderPlugin(ArgumentBuilderPluginInterface):
    def build(self, argument_list: list) -> list:
        result = []

        for argument in argument_list:
            if argument != "''":
                result.append(argument)
            else:
                result.append('')

        return result
