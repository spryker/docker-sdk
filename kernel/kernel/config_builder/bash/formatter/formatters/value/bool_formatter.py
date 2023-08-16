from kernel.config_builder.bash.formatter.formatters.formatter_interface import FormatterInterface


class BoolFormatter(FormatterInterface):
    def format(self, value) -> str:
        if isinstance(value, bool):
            return '0' if value else '1'

        return value
