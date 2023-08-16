import os
import hydra

from omegaconf import DictConfig
from typing import Optional
from docker_sdk.constant import Constant


class AbstractConfig:
    root_path: str
    data: Optional[DictConfig]

    def __init__(self, root_path: str):
        self.root_path = root_path
        self.data = None

    def get_config(self) -> DictConfig:
        if self.data is not None:
            return self.data

        config_path = os.path.join(
            self.root_path,
            Constant.CONFIG_DIRECTORY_NAME
        )
        hydra.initialize_config_dir(
            config_dir=config_path,
            version_base="1.3"
        )

        self.data = hydra.compose(config_name=Constant.CONFIG_FILE_NAME)

        return self.data

    def get_root_application_path(self) -> str:
        return self.root_path

    def get_modules_directory_path(self) -> str:
        return os.path.join(
            self.get_root_application_path(),
            Constant.MODULES_DIRECTORY_NAME
        )

    def get_data_path(self) -> str:
        return os.path.join(
            self.get_root_application_path(),
            Constant.DATA_DIRECTORY_NAME,
        )

    def get_db_path(self) -> str:
        return os.path.join(
            self.get_data_path(),
            f'{self.get_project_name()}.db'
        )

    def get_project_name(self) -> str:
        config = self.get_config()

        if Constant.CONFIG_PROJECT_NAME_KEY not in config:
            return ''

        return config[Constant.CONFIG_PROJECT_NAME_KEY]

    def get_modules_config(self) -> dict:
        config = self.get_config()

        if Constant.CONFIG_MODULES_KEY not in config:
            return {}

        return config[Constant.CONFIG_MODULES_KEY]

    def get_deployment_path(self) -> str:
        return os.path.join(
            self.get_root_application_path(),
            Constant.DEPLOYMENT_DIRECTORY_NAME
        )

    def get_deployment_path_by_project_name(self, project_name: str) -> str:
        return os.path.join(
            self.get_deployment_path(),
            project_name
        )

    def get_shared_service_list(self) -> list:
        config = self.get_config()

        if Constant.CONFIG_SHARED_SERVICES_KEY not in config:
            return []

        return config[Constant.CONFIG_SHARED_SERVICES_KEY]
