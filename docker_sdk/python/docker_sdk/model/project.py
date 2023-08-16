from typing import List
from sqlalchemy import String, Integer, Boolean, DateTime, func, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from docker_sdk.model.base import Base


class Project(Base):
    __tablename__ = 'projects'

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(30), unique=True, nullable=False)
    path: Mapped[str] = mapped_column(String(30), nullable=False)
    latest_bootable: Mapped[Boolean] = mapped_column(Boolean, default=False)
    status: Mapped[int] = mapped_column(Integer, default=0)
    data: Mapped[JSON] = mapped_column(JSON, nullable=True)
    created_at: Mapped[DateTime] = mapped_column(DateTime, nullable=False, default=func.now())
    updated_at: Mapped[DateTime] = mapped_column(DateTime, nullable=False, default=func.now(), onupdate=func.now())

    shared_services: Mapped[List["SharedServiceProject"]] = relationship(
        back_populates='project'
    )

    service_endpoints: Mapped[List["ProjectServiceEndpoint"]] = relationship(
        back_populates='project'
    )

    storage: Mapped["ProjectStorage"] = relationship(
        back_populates='project',
        uselist=False
    )

