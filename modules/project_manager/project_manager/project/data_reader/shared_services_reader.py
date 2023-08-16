import json

from project_manager.config import ProjectManagerConfig
from docker_sdk.model.project import Project


class SharedServicesReader:
    def __init__(self, config: ProjectManagerConfig):
        self.config = config

    def get_data(self, project: Project) -> dict:
        project_data = json.loads(project.data)
        services = project_data.get('services', {})

        if not services:
            return services

        shared_service_name_list = self.config.get_shared_service_list()

        return {service_name: service_data for service_name, service_data in services.items() if
                service_name in shared_service_name_list}
