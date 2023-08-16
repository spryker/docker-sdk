from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.project.processor.bootstrap.executor.bootstrap_executor_interface import BootstrapExecutorInterface
from project_manager.project.project_data_parser import ProjectDataParser
from docker_sdk.model.project import Project


class ProjectDataExecutor(BootstrapExecutorInterface):
    entity_manager: ProjectEntityManager
    project_parser: ProjectDataParser

    def __init__(self, entity_manager: ProjectEntityManager, project_parser: ProjectDataParser):
        self.entity_manager = entity_manager
        self.project_parser = project_parser

    def execute(self, project: Project) -> Project:
        project_data = self.get_project_data(project)

        return self.entity_manager.set_project_data(project, project_data)

    def get_project_data(self, project: Project) -> dict:
        return self.project_parser.parse(project.name)

