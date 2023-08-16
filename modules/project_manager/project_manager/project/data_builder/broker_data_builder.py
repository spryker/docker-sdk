from project_manager.project.data_builder.data_builder_interface import DataBuilderInterface


class BrokerBuilder(DataBuilderInterface):
    def get_service_name(self) -> str:
        return 'broker'

    def build(self, project_data: dict, shared_service_data: dict) -> dict:
        if 'api' not in shared_service_data:
            return {}

        shared_service_data['data'] = {
            'api': shared_service_data['api'],
        }

        return shared_service_data
