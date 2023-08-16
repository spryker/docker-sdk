from sqlalchemy import Integer, JSON, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from docker_sdk.model.base import Base


class ProjectStorage(Base):
    __tablename__ = 'project_storages'

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    project_id: Mapped[int] = mapped_column(Integer, ForeignKey('projects.id'))
    namespaces: Mapped[JSON] = mapped_column(JSON, nullable=True)

    project: Mapped["Project"] = relationship(back_populates="storage")
