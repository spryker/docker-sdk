from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.project.processor.bootstrap.executor.bootstrap_executor_interface import BootstrapExecutorInterface
from docker_sdk.model.project import Project


class ProjectBootstrapExecutor(BootstrapExecutorInterface):
    def __init__(self, entity_manager: ProjectEntityManager):
        self.entity_manager = entity_manager

    def execute(self, project: Project) -> Project:
        return self.entity_manager.boot_project(project)
