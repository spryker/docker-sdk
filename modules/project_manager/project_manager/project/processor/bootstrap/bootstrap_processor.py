from typing import List
from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.project.processor.bootstrap.executor.bootstrap_executor_interface import BootstrapExecutorInterface
from project_manager.project.project_data_parser import ProjectDataParser
from docker_sdk.model.project import Project


class BootstrapProcessor:
    project_entity_manager: ProjectEntityManager
    project_parser: ProjectDataParser
    bootstrap_executor_list: List[BootstrapExecutorInterface]

    def __init__(
        self,
        project_entity_manager: ProjectEntityManager,
        project_parser: ProjectDataParser,
        bootstrap_executor_list: List[BootstrapExecutorInterface]
    ):
        self.project_parser = project_parser
        self.project_entity_manager = project_entity_manager
        self.bootstrap_executor_list = bootstrap_executor_list

    def process(self, project_name: str, project_path: str) -> None:
        project = self.get_project(project_name, project_path)

        for bootstrap_executor in self.bootstrap_executor_list:
            bootstrap_executor.execute(project)

    def get_project(self, project_name: str, project_path: str) -> Project:
        return self.project_entity_manager.get_project(project_name, project_path)

    def get_project_data(self, project: Project) -> dict:
        return self.project_parser.parse(project.name)
