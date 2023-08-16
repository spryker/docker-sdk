from typing import List
from sqlalchemy import Engine
from docker_sdk.model.base import Base


class ModelMigration:
    def __init__(self, models: List[Base], db_engine: Engine):
        self.__models = models
        self.__db_engine = db_engine

    def migrate(self):
        for model in self.__models:
            model.metadata.create_all(self.__db_engine)
