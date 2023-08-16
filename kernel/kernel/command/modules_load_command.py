from kernel.sdk_modules.builder.module_builder import ModuleBuilder
from docker_sdk.application.command_manager.command.command_interface import CommandInterface


class ModulesLoadCommand(CommandInterface):
    def __init__(self, module_builder: ModuleBuilder):
        self.module_builder = module_builder

    def run(self, argv: list):
        self.module_builder.build()

    def get_name(self) -> str:
        return 'modules-load'
