from project_manager.project.processor.init.init_processor import InitProcessor
from docker_sdk.application.command_manager.command.command_interface import CommandInterface


class InitCommand(CommandInterface):
    init_processor: InitProcessor

    def __init__(self, init_processor: InitProcessor):
        self.init_processor = init_processor

    def run(self, argv: list):
        project_name = argv[0]
        project_path = argv[1]

        self.init_processor.init(project_name, project_path)

        return

    def get_name(self) -> str:
        return 'project_init'
