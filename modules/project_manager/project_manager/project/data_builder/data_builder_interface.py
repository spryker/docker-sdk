import abc


class DataBuilderInterface(abc.ABC):
    @abc.abstractmethod
    def build(self, project_data: dict, shared_service_data: dict) -> dict:
        pass

    @abc.abstractmethod
    def get_service_name(self) -> str:
        pass
