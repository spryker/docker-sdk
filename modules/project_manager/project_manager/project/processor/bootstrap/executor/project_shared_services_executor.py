import json
from typing import List

from project_manager.entity_manager.shared_service_entity_manager import SharedServiceEntityManager
from project_manager.project.data_builder.data_builder_interface import DataBuilderInterface
from project_manager.project.data_reader.shared_services_reader import SharedServicesReader
from project_manager.project.processor.bootstrap.executor.bootstrap_executor_interface import BootstrapExecutorInterface
from docker_sdk.model.project import Project


class ProjectSharedServicesExecutor(BootstrapExecutorInterface):
    shared_service_entity_manager: SharedServiceEntityManager
    data_builder_list: List[DataBuilderInterface]
    shared_services_reader: SharedServicesReader

    def __init__(
        self,
        shared_service_entity_manager: SharedServiceEntityManager,
        shared_services_reader: SharedServicesReader,
        data_builder_list: List[DataBuilderInterface]
    ):
        self.shared_service_entity_manager = shared_service_entity_manager
        self.shared_services_reader = shared_services_reader
        self.data_builder_list = data_builder_list

    def execute(self, project: Project) -> Project:
        project_data = json.loads(project.data)
        shared_services_data = self.shared_services_reader.get_data(project)

        for data_builder in self.data_builder_list:
            if data_builder.get_service_name() in shared_services_data:
                shared_services_data[data_builder.get_service_name()] = data_builder.build(
                    project_data,
                    shared_services_data[data_builder.get_service_name()]
                )

        self.create_or_update_shared_services(project, shared_services_data)

        return project

    def create_or_update_shared_services(self, project: Project, shared_services_data: dict) -> None:
        if not shared_services_data:
            return

        for service_name, service_data in shared_services_data.items():
            self.shared_service_entity_manager.create_or_update_shared_service(
                project,
                service_name,
                service_data
            )
