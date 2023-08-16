from typing import Union
from omegaconf import DictConfig
from kernel.config_builder.config_formatter_interface import ConfigFormatterInterface
from kernel.constant import KernelConstant


class BashConfigFormatter(ConfigFormatterInterface):
    def __init__(self, value_formatters: list, key_formatters: list):
        self.key_formatters = key_formatters
        self.value_formatters = value_formatters

    def format(self, config: DictConfig) -> dict:
        result = {}
        config = self.flatten_config(config)

        for key, value in config.items():
            for key_formatter in self.key_formatters:
                key = key_formatter.format(key)

            for formatter in self.value_formatters:
                value = formatter.format(value)

            result[key] = f'{value}'

        return result

    def flatten_config(self, config: Union[dict, DictConfig], parent_key: str = '', sep=KernelConstant.CONFIG_BASH_KEY_SEPARATOR):
        result = {}

        for key, value in config.items():
            new_key = f"{parent_key}{sep}{key}" if parent_key else key

            if isinstance(value, dict) or isinstance(value, DictConfig):
                result.update(self.flatten_config(value, new_key, sep=sep).items())
            else:
                result[new_key] = value

        return result
