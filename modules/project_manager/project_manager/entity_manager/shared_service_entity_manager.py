from project_manager.entity_manager.abstract_entity_manager import AbstractEntityManager
from docker_sdk.model.project import Project
from docker_sdk.model.shared_service import SharedService
from docker_sdk.model.shared_service_project import SharedServiceProject


class SharedServiceEntityManager(AbstractEntityManager):
    def create_or_update_shared_service(self, project, service_name, service_data) -> SharedService:
        shared_service = self.find_or_create_shared_service(service_name, service_data)
        shared_service_project = self.find_or_create_shared_service_project(project, shared_service, service_data)

        shared_service.projects.append(shared_service_project)

        return shared_service

    def find_or_create_shared_service_project(
        self,
        project: Project,
        shared_service: SharedService,
        service_data: dict
    ) -> SharedServiceProject:
        shared_service_project = self.session.query(SharedServiceProject).filter(
            SharedServiceProject.shared_service_id == shared_service.id,
            SharedServiceProject.project_id == project.id
        ).first()

        if not shared_service_project:
            shared_service_project = SharedServiceProject(
                project_id=project.id,
                shared_service_id=shared_service.id,
            )

            shared_services_project_list = self.session.query(SharedServiceProject).filter(
                SharedServiceProject.shared_service_id == shared_service.id,
            ).all()

            if len(shared_services_project_list) == 0:
                shared_service_project.init_project = True

        shared_service_project.data = service_data['data'] if 'data' in service_data else None
        shared_service_project.endpoints = service_data['endpoints'] if 'endpoints' in service_data else None

        self.session.add(shared_service_project)
        self.session.commit()

        return shared_service_project

    def find_or_create_shared_service(self, service_name: str, service_data: dict) -> SharedService:
        shared_service = self.session.query(SharedService).filter(
            SharedService.name == service_name
        ).first()

        if shared_service:
            self.validate_existed_shared_service(shared_service, service_data)

            return shared_service

        shared_service = SharedService(
            name=service_name,
            engine=service_data['engine'],
            version=service_data['version'] if 'version' in service_data else 'default',
        )

        self.session.add(shared_service)
        self.session.commit()

        return shared_service

    def validate_existed_shared_service(self, shared_service: SharedService, service_data: dict) -> None:
        engine = service_data['engine']
        version = service_data['version'] if 'version' in service_data else 'default'

        if shared_service.engine != engine:
            raise Exception('Shared service engine is not equal.')

        if shared_service.version != version:
            raise Exception('Shared service version is not equal.')

