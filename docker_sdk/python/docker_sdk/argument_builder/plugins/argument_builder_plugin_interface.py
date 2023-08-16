from abc import ABC, abstractmethod


class ArgumentBuilderPluginInterface(ABC):
    @abstractmethod
    def build(self, argument_list: list) -> list:
        pass
