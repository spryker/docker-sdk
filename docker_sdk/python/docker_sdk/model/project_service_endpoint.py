from sqlalchemy import Integer, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from docker_sdk.model.base import Base


class ProjectServiceEndpoint(Base):
    __tablename__ = 'project_service_endpoints'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    project_id: Mapped[int] = mapped_column(Integer, ForeignKey('projects.id'))
    service_name: Mapped[str] = mapped_column(String(30), nullable=False)
    endpoint: Mapped[str] = mapped_column(String(30), nullable=False)

    project: Mapped["Project"] = relationship(
        back_populates="service_endpoints"
    )
