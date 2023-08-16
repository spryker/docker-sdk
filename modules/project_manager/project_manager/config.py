import os

from docker_sdk.config.abstract_config import AbstractConfig


class ProjectManagerConfig(AbstractConfig):

    def get_project_yml_file_name(self) -> str:
        return 'project.yml'

    def get_project_yml_file_path_by_project_name(self, project_name: str) -> str:
        return os.path.join(
            self.get_deployment_path_by_project_name(project_name),
            self.get_project_yml_file_name()
        )
