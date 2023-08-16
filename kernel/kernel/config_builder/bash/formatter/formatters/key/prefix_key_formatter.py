from kernel.config_builder.bash.formatter.formatters.formatter_interface import FormatterInterface
from kernel.constant import KernelConstant


class PrefixKeyFormatter(FormatterInterface):
    def format(self, value) -> str:
        key = KernelConstant.CONFIG_BASH_KEY_PREFIX + KernelConstant.CONFIG_BASH_KEY_SEPARATOR + value
        key = key.upper()

        return key
