from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.project.name_builder.project_name_builder import ProjectNameBuilder
from docker_sdk.application.command_manager.command.command_interface import CommandInterface


class GetNameCommand(CommandInterface):
    project_entity_manager: ProjectEntityManager

    def __init__(self, project_entity_manager: ProjectEntityManager):
        self.project_entity_manager = project_entity_manager

    def run(self, argv: list):
        project_name = argv[0]
        project_path = argv[1]

        if project_name != '':
            print(project_name.strip())

            return

        latest_bootable_project = self.project_entity_manager.get_last_bootable_projects_by_path(project_path)

        if latest_bootable_project is not None:
            project_name = latest_bootable_project.name

            print(project_name.strip())

            return

        project = self.project_entity_manager.get_latest_created_project_by_path(project_path)

        if project is not None:
            print(project.name.strip())

            return

        print(ProjectNameBuilder().get_project_name_from_path(project_path))

        return

    def get_name(self) -> str:
        return 'project_get_name'
