import json
from project_manager.entity_manager.abstract_entity_manager import AbstractEntityManager
from docker_sdk.model.project import Project
from docker_sdk.model.project_storage import ProjectStorage


class StorageEntityManager(AbstractEntityManager):
    def commit_storage(self, storage) -> None:
        self.session.add(storage)
        self.session.commit()

    def get_all_storages(self) -> list:
        return self.session.query(ProjectStorage).all()

    def create_or_update_storage_by_project(self, project: Project, storage_namespace_list: list) -> Project:
        storage_namespace_list = json.dumps(storage_namespace_list)

        project_storage = project.storage

        if project_storage is None:
            project_storage = ProjectStorage(
                project_id=project.id,
                namespaces=storage_namespace_list,
            )

            project.storage = project_storage
        # todo: check project save
        self.commit_storage(project_storage)

        return project
