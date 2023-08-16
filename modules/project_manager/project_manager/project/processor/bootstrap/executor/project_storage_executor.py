import json

from project_manager.entity_manager.storage_entit_manager import StorageEntityManager
from project_manager.project.data_reader.storage_data_reader import StorageDataReader
from project_manager.project.processor.bootstrap.executor.bootstrap_executor_interface import BootstrapExecutorInterface
from docker_sdk.model.project import Project


class ProjectStorageExecutor(BootstrapExecutorInterface):
    storage_data_reader: StorageDataReader
    storage_entity_manager: StorageEntityManager

    def __init__(self, storage_entity_manager: StorageEntityManager, storage_data_reader: StorageDataReader):
        self.storage_entity_manager = storage_entity_manager
        self.storage_data_reader = storage_data_reader

    def execute(self, project: Project) -> Project:
        storage_namespace_list = self.storage_data_reader.get_data(project)

        self.validate_storage(project, storage_namespace_list)

        return self.storage_entity_manager.create_or_update_storage_by_project(project, storage_namespace_list)

    def validate_storage(self, project: Project, storage_data: list) -> None:
        storages = self.storage_entity_manager.get_all_storages()

        if len(storages) == 0:
            return

        intersection = set()

        for storage in storages:
            if storage.project.name == project.name:
                continue

            namespaces = json.loads(storage.namespaces)
            intersection = set(storage_data) & set(namespaces)

        if len(intersection) != 0:
            raise Exception(
                'Storage namespaces intersection. Please, check your project namespaces:' + str(intersection)
            )
