from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from docker_sdk.application.command_manager.command.command_interface import CommandInterface
from docker_sdk.table_formatter.TableFormatter import TableFormatter


class InfoCommand(CommandInterface):
    def __init__(self, project_entity_manager: ProjectEntityManager, table_formatter: TableFormatter):
        self.__project_entity_manager = project_entity_manager
        self.__table_formatter = table_formatter

    def run(self, argv: list):
        project_name = argv[0]
        project_path = argv[1]

        project = self.__project_entity_manager.get_project(project_name, project_path)

        if project is not None:
            headers = ['Project Name', 'Project Path']
            row = [project.name, project.path]

            print(self.__table_formatter.get_table([row], headers))

    def get_name(self) -> str:
        return 'project_info'
