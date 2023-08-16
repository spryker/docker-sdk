import abc

from omegaconf import DictConfig


class ConfigFormatterInterface(abc.ABC):
    @abc.abstractmethod
    def format(self, config: DictConfig) -> dict:
        pass
