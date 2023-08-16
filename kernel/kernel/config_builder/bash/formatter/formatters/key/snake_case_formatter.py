from kernel.config_builder.bash.formatter.formatters.formatter_interface import FormatterInterface


class SnakeCaseFormatter(FormatterInterface):
    def format(self, value) -> str:
        key = str(value).replace("-", "_")
        key = ''.join(['_' + i.lower() if i.isupper() else i for i in key]).lstrip('_')

        return key
