from kernel.config_builder.abstract_config_render import AbstractConfigRender


class YmlConfigRender(AbstractConfigRender):
    def get_template_file_name(self) -> str:
        return self.config.get_sdk_yml_config_template_file_name()

    def get_output_path(self) -> str:
        return self.config.get_config_yml_file_path()
