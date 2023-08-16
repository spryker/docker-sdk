from docker_sdk.application.command_manager.command_manager import CommandManager


class Application:
    command_manager: CommandManager

    def __init__(self, command_manager: CommandManager):
        self.command_manager = command_manager

    def run(self, argv: list):
        self.command_manager.run(argv)
