from kernel.sdk_db.db_creator.db_creator import DbCreator
from docker_sdk.application.command_manager.command.command_interface import CommandInterface


class InitSdkDbCommand(CommandInterface):
    db_creator: DbCreator

    def __init__(self, db_creator: DbCreator):
        self.db_creator = db_creator

    def run(self, argv: list):
        self.db_creator.create()

    def get_name(self) -> str:
        return 'init-db'
