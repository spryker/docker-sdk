import os
import yaml

from project_manager.config import ProjectManagerConfig


class ProjectDataParser:
    __config: ProjectManagerConfig
    __data: dict

    def __init__(self, config: ProjectManagerConfig):
        self.__config = config
        self.__data = {}

    def parse(self, project_name: str) -> dict:
        deployment_path = self.__config.get_project_yml_file_path_by_project_name(project_name)
        self.__data = yaml.safe_load(open(deployment_path))

        return self.__data

