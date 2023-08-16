from sqlalchemy import Integer, ForeignKey
from sqlalchemy.dialects.sqlite import JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from docker_sdk.model.base import Base


class SharedServiceProject(Base):
    __tablename__ = 'shared_services_projects'

    shared_service_id: Mapped[int] = mapped_column(Integer, ForeignKey('shared_services.id'), primary_key=True)
    project_id: Mapped[int] = mapped_column(Integer, ForeignKey('projects.id'), primary_key=True)
    data: Mapped[JSON] = mapped_column(JSON, nullable=True)
    endpoints: Mapped[JSON] = mapped_column(JSON, nullable=True)
    init_project: Mapped[bool] = mapped_column(Integer, default=0)

    shared_service: Mapped["SharedService"] = relationship(back_populates="projects")
    project: Mapped["Project"] = relationship(back_populates="shared_services")
