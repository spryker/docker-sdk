import dpath

from project_manager.project.data_builder.data_builder_interface import DataBuilderInterface


class RedisGuiDataBuilder(DataBuilderInterface):
    def get_service_name(self) -> str:
        return 'redis-gui'

    def build(self, project_data: dict, shared_service_data: dict) -> dict:
        storage_services = self.get_storage_services(project_data)

        if not storage_services:
            return shared_service_data

        groups_storage_data = self.get_storage_data_from_groups(project_data, storage_services)
        regions_storage_data = self.get_storage_data_from_regions(project_data, storage_services)

        storage_data = groups_storage_data + regions_storage_data

        shared_service_data['data'] = {
            'hosts': self.build_hosts(storage_data),
            'services': storage_services,
        }

        return shared_service_data

    def get_storage_services(self, project_data: dict, engine='redis'):
        services = project_data.get('services', {})

        return {key: value for key, value in services.items() if value['engine'] == engine}

    def get_storage_data_from_groups(self, project_data, storage_services) -> list:
        groups = project_data.get('groups', [])

        if not groups:
            return []

        data = dpath.values(groups, '/*/applications/*/endpoints/*/services')

        return self.filter_storage_services(data, storage_services)

    def filter_storage_services(self, data, storage_services) -> list:
        result = []

        for service_data in data:
            if not service_data:
                continue

            for service_name, service_value in service_data.items():
                if service_name in storage_services:
                    namespace = service_value.get('namespace')

                    if namespace:
                        result.append({
                            service_name: {
                                'namespace': namespace,
                            }
                        })

        return result

    def get_storage_data_from_regions(self, project_data, storage_services) -> list:
        result = []
        regions = project_data.get('regions', [])

        if not regions:
            return result

        # data = [region.get('services', {}) for region in regions]
        data = dpath.values(regions, '/*/services')
        data = self.filter_storage_services(data, storage_services)

        result.extend(data)

        data = dpath.values(regions, '/*/stores/*/services')
        data = self.filter_storage_services(data, storage_services)

        result.extend(data)

        return result

    def build_hosts(self, storage_data: list) -> list:
        hosts = []

        for service_data in storage_data:
            service_name = list(service_data.keys())[0]
            service_data = service_data[service_name]
            namespace = service_data.get('namespace')

            hosts.append(f'{service_name}:{service_name}:6379:{namespace}')

        return hosts
