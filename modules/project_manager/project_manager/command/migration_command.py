from docker_sdk.model_migration.model_migration import ModelMigration
from docker_sdk.application.command_manager.command.command_interface import CommandInterface


class MigrationCommand(CommandInterface):
    def __init__(self, model_migration: ModelMigration):
        self.__model_migration = model_migration

    def run(self, argv: list):
        self.__model_migration.migrate()

    def get_name(self) -> str:
        return 'migration'
