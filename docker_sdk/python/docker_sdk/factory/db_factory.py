from sqlalchemy import create_engine, Engine
from sqlalchemy.orm import Session
from docker_sdk.config.abstract_config import AbstractConfig


class DbFactory:
    config: AbstractConfig
    session: Session

    def __init__(self, config: AbstractConfig):
        self.config = config
        self.session = Session(self.get_engine())

    def get_engine(self) -> Engine:
        return create_engine(
            'sqlite:///' + self.config.get_db_path(),
            echo=False,
        )

    def get_session(self) -> Session:
        return self.session

