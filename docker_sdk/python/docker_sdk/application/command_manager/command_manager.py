from typing import List
from docker_sdk.application.command_manager.command.command_interface import CommandInterface


class CommandManager:
    commands: List[CommandInterface]

    def __init__(self, commands: List[CommandInterface]):
        self.commands = commands

    def run(self, argv: list):
        if len(argv) == 0:
            command_list = []

            for command in self.commands:
                command_list.append(command.get_name())

            raise Exception('Command not specified. Available commands: ' + ', '.join(command_list))

        self.get_command(argv[0]).run(argv[1:])

    def get_command(self, command_name: str) -> CommandInterface:
        for command in self.commands:
            if command.get_name() == command_name:
                return command

        raise Exception(f'Command not found: `{command_name}`.')
