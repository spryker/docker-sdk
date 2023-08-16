import json
import dpath

from docker_sdk.model.project import Project


class StorageDataReader:
    def get_data(self, project: Project) -> list:
        project_data = json.loads(project.data)
        services = project_data.get('services', [])

        if not services:
            return services

        storage_services = self.get_storage_services(services)

        if not storage_services:
            return storage_services

        groups_storage_data = self.get_storage_data_from_groups(project_data, storage_services)
        regions_storage_data = self.get_storage_data_from_regions(project_data, storage_services)

        result = groups_storage_data + regions_storage_data
        result = [item for item in result if item]

        result = list(set(result))
        result.sort()

        return result

    def get_storage_services(self, services, engine='redis') -> list:
        return [{service_name: service_data} for service_name, service_data in services.items() if
                service_data['engine'] == engine]

    def get_storage_data_from_groups(self, project_data, storage_services) -> list:
        result = []
        groups = project_data.get('groups', [])

        if not groups:
            return result

        data = self.data_get(groups, '/*/applications/*/endpoints/*/services')

        return self.filter_storage_services(data, storage_services)

    def filter_storage_services(self, data, storage_services) -> list:
        result = []

        for service_data in data:
            if not service_data:
                continue

            service_names = list(service_data.keys())

            if not service_names:
                continue

            for service_name in service_names:
                for storage_service in storage_services:
                    if service_name in storage_service:
                        result.append(service_data[service_name]['namespace'])

        return result

    def get_storage_data_from_regions(self, project_data, storage_services) -> list:
        result = []
        regions = project_data.get('regions', [])

        if not regions:
            return result

        data = self.data_get(regions, '/*/services')
        data = self.filter_storage_services(data, storage_services)

        result = data + result

        data = self.data_get(regions, '/*/stores/*/services')
        data = self.filter_storage_services(data, storage_services)

        return data + result

    def data_get(self, data: dict, keys: str) -> list:
        return dpath.values(data, keys)
