from omegaconf import ListConfig
from kernel.config_builder.bash.formatter.formatters.formatter_interface import FormatterInterface


class ListFormatter(FormatterInterface):
    def format(self, value) -> str:
        if isinstance(value, list) or isinstance(value, ListConfig):
            value = [f'{str(item)}' for item in value]
            value_string = ' '.join(value)
            return f'({value_string})'

        return value
