from docker_sdk.application.command_manager.command.command_interface import CommandInterface
from project_manager.project.processor.bootstrap.bootstrap_processor import BootstrapProcessor


class BootCommand(CommandInterface):
    bootstrap_processor: BootstrapProcessor

    def __init__(self, bootstrap_processor: BootstrapProcessor):
        self.bootstrap_processor = bootstrap_processor

    def run(self, argv: list) -> None:
        project_name = argv[0]
        project_path = argv[1]

        self.bootstrap_processor.process(project_name, project_path)

    def get_name(self) -> str:
        return 'project_boot'
