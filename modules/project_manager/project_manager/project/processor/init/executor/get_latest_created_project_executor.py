from typing import Optional

from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.project.processor.init.executor.init_executor_interface import InitExecutorInterface
from docker_sdk.model.project import Project


class GetLatestCreatedProjectExecutor(InitExecutorInterface):
    project_entity_manager: ProjectEntityManager

    def __init__(self, project_entity_manager: ProjectEntityManager, ):
        self.project_entity_manager = project_entity_manager

    def exec(self, project_name: str, project_path: str) -> Optional[Project]:
        if project_name != '':
            return None

        return self.project_entity_manager.get_latest_created_project_by_path(project_path)
