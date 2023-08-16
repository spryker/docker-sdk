import yaml

from omegaconf import DictConfig, OmegaConf
from kernel.config_builder.config_formatter_interface import ConfigFormatterInterface


class YmlConfigFormatter(ConfigFormatterInterface):
    def format(self, config: DictConfig) -> dict:
        return {
            'yml': OmegaConf.to_yaml(config, resolve=True)
        }
