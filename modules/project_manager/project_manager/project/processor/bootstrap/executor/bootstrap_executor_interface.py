import abc

from docker_sdk.model.project import Project


class BootstrapExecutorInterface(abc.ABC):
    @abc.abstractmethod
    def execute(self, project: Project) -> Project:
        pass
