from typing import List
from project_manager.command.boot_command import BootCommand
from project_manager.command.get_name_command import GetNameCommand
from project_manager.command.info_command import InfoCommand
from project_manager.command.init_command import InitCommand
from project_manager.command.migration_command import MigrationCommand
from project_manager.config import ProjectManagerConfig
from project_manager.entity_manager.project_entity_manager import ProjectEntityManager
from project_manager.entity_manager.shared_service_entity_manager import SharedServiceEntityManager
from project_manager.entity_manager.storage_entit_manager import StorageEntityManager
from project_manager.project.data_builder.broker_data_builder import BrokerBuilder
from project_manager.project.data_builder.data_builder_interface import DataBuilderInterface
from project_manager.project.data_builder.redis_gui_data_builder import RedisGuiDataBuilder
from project_manager.project.data_reader.shared_services_reader import SharedServicesReader
from project_manager.project.data_reader.storage_data_reader import StorageDataReader
from project_manager.project.processor.bootstrap.bootstrap_processor import BootstrapProcessor
from project_manager.project.processor.bootstrap.executor.project_bootstrap_executor import ProjectBootstrapExecutor
from project_manager.project.processor.bootstrap.executor.project_data_executor import ProjectDataExecutor
from project_manager.project.processor.bootstrap.executor.project_shared_services_executor import \
    ProjectSharedServicesExecutor
from project_manager.project.processor.bootstrap.executor.project_storage_executor import ProjectStorageExecutor
from project_manager.project.processor.init.executor.get_latest_bootable_project_executor import \
    GetLatestBootableProjectExecutor
from project_manager.project.processor.init.executor.get_latest_created_project_executor import \
    GetLatestCreatedProjectExecutor
from project_manager.project.processor.init.executor.get_project_executor import GetProjectExecutor
from project_manager.project.processor.init.executor.init_executor_interface import InitExecutorInterface
from project_manager.project.processor.init.init_processor import InitProcessor
from project_manager.project.project_data_parser import ProjectDataParser
from docker_sdk.factory.abstract_application_factory import AbstractApplicationFactory
from docker_sdk.factory.db_factory import DbFactory
from docker_sdk.model.project import Project
from docker_sdk.model.project_service_endpoint import ProjectServiceEndpoint
from docker_sdk.model.project_storage import ProjectStorage
from docker_sdk.model.shared_service import SharedService
from docker_sdk.model.shared_service_project import SharedServiceProject
from docker_sdk.model_migration.model_migration import ModelMigration


class ProjectManagerFactory(DbFactory, AbstractApplicationFactory):
    config: ProjectManagerConfig

    def get_config(self) -> ProjectManagerConfig:
        return self.config

    def get_application_command_class_list(self):
        return [
            InitCommand(self.get_project_init_processor()),
            BootCommand(self.get_bootstrap_processor()),
            InfoCommand(
                self.get_project_entity_manager(),
                self.get_table_formatter(),
            ),
            MigrationCommand(
                self.get_model_migration(),
            ),
            GetNameCommand(self.get_project_entity_manager()),
        ]

    def get_project_entity_manager(self):
        return ProjectEntityManager(
            self.get_session(),
            self.get_config()
        )

    def get_model_list(self) -> list:
        return [
            Project,
            SharedService,
            SharedServiceProject,
            ProjectServiceEndpoint,
            ProjectStorage,
        ]

    def get_model_migration(self) -> ModelMigration:
        return ModelMigration(
            self.get_model_list(),
            self.get_engine()
        )

    def get_project_init_processor(self) -> InitProcessor:
        return InitProcessor(
            self.get_project_entity_manager(),
            self.get_init_executor_list(),
        )

    def get_bootstrap_processor(self) -> BootstrapProcessor:
        return BootstrapProcessor(
            self.get_project_entity_manager(),
            self.get_project_data_parser(),
            self.get_bootstrap_executor_list(),
        )

    def get_bootstrap_executor_list(self):
        return [
            ProjectBootstrapExecutor(self.get_project_entity_manager()),
            ProjectDataExecutor(self.get_project_entity_manager(), self.get_project_data_parser()),
            ProjectStorageExecutor(self.get_storage_entity_manager(), self.get_storage_data_reader()),
            ProjectSharedServicesExecutor(
                self.get_shared_service_entity_manager(),
                self.get_shared_service_data_reader(),
                self.get_shared_services_data_builder_list()
            ),
        ]

    def get_project_data_parser(self):
        return ProjectDataParser(self.get_config())

    def get_init_executor_list(self) -> List[InitExecutorInterface]:
        return [
            GetProjectExecutor(self.get_project_entity_manager()),
            GetLatestBootableProjectExecutor(self.get_project_entity_manager()),
            GetLatestCreatedProjectExecutor(self.get_project_entity_manager()),
        ]

    def get_storage_entity_manager(self) -> StorageEntityManager:
        return StorageEntityManager(
            self.get_session(),
            self.get_config()
        )

    def get_storage_data_reader(self) -> StorageDataReader:
        return StorageDataReader()

    def get_shared_service_data_reader(self) -> SharedServicesReader:
        return SharedServicesReader(self.get_config())

    def get_shared_services_data_builder_list(self) -> List[DataBuilderInterface]:
        return [
            BrokerBuilder(),
            RedisGuiDataBuilder(),
        ]

    def get_shared_service_entity_manager(self) -> SharedServiceEntityManager:
        return SharedServiceEntityManager(
            self.get_session(),
            self.get_config()
        )
