import abc

from jinja2 import Environment
from kernel.config import KernelConfig


class AbstractConfigRender(abc.ABC):
    def __init__(self, config: KernelConfig, jinja: Environment):
        self.jinja = jinja
        self.config = config

    def render(self, config: dict) -> None:
        self.jinja \
            .get_template(self.get_template_file_name()) \
            .stream({'config': config}) \
            .dump(self.get_output_path())

    @abc.abstractmethod
    def get_template_file_name(self) -> str:
        pass

    @abc.abstractmethod
    def get_output_path(self) -> str:
        pass
