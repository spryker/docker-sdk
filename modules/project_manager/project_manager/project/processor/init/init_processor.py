from typing import List
from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.project.processor.init.executor.init_executor_interface import InitExecutorInterface


class InitProcessor:
    project_entity_manager: ProjectEntityManager
    init_executor_list: List[InitExecutorInterface]

    def __init__(self, project_entity_manager: ProjectEntityManager, init_executor_list: List[InitExecutorInterface]):
        self.project_entity_manager = project_entity_manager
        self.init_executor_list = init_executor_list

    def init(self, project_name: str, project_path: str):
        project = self.project_entity_manager.get_project_by_name(project_name)

        if project is not None and project.path is not project_path:
            raise Exception(f'Project with name `{project_name}` already exists.')

        for init_executor in self.init_executor_list:
            project = init_executor.exec(project_name, project_path)

            if project is not None:
                return

        self.project_entity_manager.create_project(project_name, project_path)
