from typing import List

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from docker_sdk.model.base import Base


class SharedService(Base):
    __tablename__ = 'shared_services'

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(30), unique=True)
    engine: Mapped[str] = mapped_column(String(30))
    version: Mapped[str] = mapped_column(String(30))

    projects: Mapped[List["SharedServiceProject"]] = relationship(
        back_populates='shared_service'
    )
