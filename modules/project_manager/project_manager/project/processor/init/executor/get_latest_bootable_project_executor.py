from typing import Optional
from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.project.processor.init.executor.init_executor_interface import InitExecutorInterface
from docker_sdk.model.project import Project


class GetLatestBootableProjectExecutor(InitExecutorInterface):
    project_entity_manager: ProjectEntityManager

    def __init__(self, project_entity_manager: ProjectEntityManager, ):
        self.project_entity_manager = project_entity_manager

    def exec(self, project_name: str, project_path: str) -> Optional[Project]:
        if project_name != '':
            return None

        return self.project_entity_manager.get_last_bootable_projects_by_path(project_path)
