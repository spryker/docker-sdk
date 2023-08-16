import json

from typing import Optional
from project_manager.entity_manager.abstract_entity_manager import AbstractEntityManager
from project_manager.project.name_builder.project_name_builder import ProjectNameBuilder
from docker_sdk.model.project import Project


class ProjectEntityManager(AbstractEntityManager):
    def get_project(self, project_name: str, project_path: str) -> Optional[Project]:
        return self.session.query(Project).filter(
            Project.name == project_name,
            Project.path == project_path
        ).first()

    def get_project_by_name(self, project_name: str):
        return self.session.query(Project).filter(
            Project.name == project_name
        ).first()

    def get_project_by_path(self, project_path: str):
        return self.session.query(Project).filter(
            Project.path == project_path
        ).first()

    def get_all_projects(self):
        return self.session.query(Project).all()

    def get_all_projects_by_path(self, project_path: str):
        return self.session.query(Project).filter(Project.path == project_path).all()

    def remove_project(self, project: Project):
        self.session.delete(project)
        self.session.commit()

    def remove_project_by_name(self, project_name: str):
        project = self.get_project_by_name(project_name)

        if project is None:
            return

        self.session.delete(project)
        self.session.commit()

    def get_last_bootable_projects_by_path(self, project_path: str):
        return self.session.query(Project).filter(
            Project.path == project_path,
            Project.latest_bootable == True
        ).first()

    def get_latest_created_project_by_path(self, project_path: str):
        return self.session.query(Project).filter(
            Project.path == project_path
        ).order_by(
            Project.created_at.desc()
        ).first()

    def create_project(self, project_name: str, project_path: str) -> Project:
        if project_name == '':
            project_name = ProjectNameBuilder.get_project_name_from_path(project_path)

        project = Project(
            name=project_name,
            path=project_path,
        )

        self.session.add(project)
        self.session.commit()

        return project

    def boot_project(self, project: Project) -> Project:
        self.session.query(Project).filter(
            Project.path == project.path
        ).update({Project.latest_bootable: False})

        project.latest_bootable = True

        self.session.commit()

        return project

    def set_project_data(self, project: Project, data: dict) -> Project:
        project.data = json.dumps(data)

        self.session.commit()

        return project
