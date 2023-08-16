import abc

from sqlalchemy.orm import Session
from project_manager.config import ProjectManagerConfig


class AbstractEntityManager(abc.ABC):
    session: Session
    config: ProjectManagerConfig

    def __init__(self, session: Session, config: ProjectManagerConfig):
        self.config = config
        self.session = session
