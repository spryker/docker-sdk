from kernel.config_builder.abstract_config_render import AbstractConfigRender


class BashConfigRender(AbstractConfigRender):
    def get_template_file_name(self) -> str:
        return self.config.get_sdk_bash_config_template_file_name()

    def get_output_path(self) -> str:
        return self.config.get_config_bash_file_path()
