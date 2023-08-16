from abc import ABC, abstractmethod


class CommandInterface(ABC):
    @abstractmethod
    def run(self, argv: list):
        pass

    @abstractmethod
    def get_name(self) -> str:
        pass
