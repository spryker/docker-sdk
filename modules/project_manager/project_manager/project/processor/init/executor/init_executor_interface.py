import abc

from typing import Optional
from docker_sdk.model.project import Project


class InitExecutorInterface(abc.ABC):
    @abc.abstractmethod
    def exec(self, project_name: str, project_path: str) -> Optional[Project]:
        pass
