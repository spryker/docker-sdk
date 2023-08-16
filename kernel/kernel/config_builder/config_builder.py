from kernel.config import KernelConfig
from kernel.config_builder.abstract_config_render import AbstractConfigRender
from kernel.config_builder.config_formatter_interface import ConfigFormatterInterface


class ConfigBuilder:
    def __init__(
        self,
        config_formatter: ConfigFormatterInterface,
        config: KernelConfig,
        render: AbstractConfigRender,
    ):
        self.config = config
        self.config_formatter = config_formatter
        self.render = render

    def build(self):
        config = self.config_formatter.format(self.config.get_config())
        self.render.render(config)

