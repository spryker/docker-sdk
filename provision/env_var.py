import boto3
import logging
import json
import yaml
import re
import os
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO)

def ssm_put_parameter(parameter_name, parameter_value, parameter_type):
    """Creates new parameter in AWS SSM
    :param parameter_name: Name of the parameter to create in AWS SSM
    :param parameter_value: Value of the parameter to create in AWS SSM
    :param parameter_type: Type of the parameter to create in AWS SSM ('String'|'StringList'|'SecureString')
    :return: Return version of the parameter if successfully created else None
    """
    ssm_client = boto3.client('ssm')

    try:
        result = ssm_client.put_parameter(
            Name='/{}/custom-secrets/{}'.format(os.environ['SPRYKER_PROJECT_NAME'], parameter_name),
            Value=parameter_value,
            Type=parameter_type,
            Overwrite=True
        )
    except ClientError as e:
        logging.error(e)
        return None
    return result['Version']

def read_deploy_file(yaml_file_to_read="/provision/project.yml"):
    with open(yaml_file_to_read, "r") as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as e:
            logging.info('An error occurred:' + e)
            return None

def update_active_stores(deploy_file_data):
    logging.info('[ACTIVE_STORE]')
    stores = []

    for region_name, region_data in deploy_file_data['regions'].items():
        if 'stores' in region_data:
            for store_name in region_data['stores']:
                stores.append(store_name)

    stores = ",".join(stores)
    logging.info('[ACTIVE_STORE] {}'.format(stores))
    ssm_put_parameter('SPRYKER_ACTIVE_STORES', stores, 'SecureString')

def update_end_point_lists(deploy_file_data):
    logging.info("[ENDPOINT LIST]")

    endpoint_lists = {}

    for group_name, group_data in deploy_file_data['groups'].items():
        if 'applications' in group_data:
             for application_name, application_data in group_data['applications'].items():
                for endpoint_name, endpoint_data in application_data['endpoints'].items():
                    if 'store' not in endpoint_data:
                        continue
                    if endpoint_data['store'] not in endpoint_lists:
                        endpoint_lists.update({ endpoint_data['store']: {}})
                    endpoint_lists[endpoint_data['store']].update(endpoint_lists[endpoint_data['store']] | {
                        re.sub(r'(?<!^)(?=[A-Z])', '-', application_name).lower(): endpoint_name
                    })

    logging.info('[ENDPOINT LIST] {}' . format(json.dumps(endpoint_lists)))
    ssm_put_parameter('SPRYKER_ENDPOINT_LIST', json.dumps(endpoint_lists), 'SecureString')

def main():
    try:
        deploy_file_data = read_deploy_file()
        update_active_stores(deploy_file_data)
        update_end_point_lists(deploy_file_data)
    except Exception as e:
        logging.error(e)
        exit(1)
    exit(0)

if __name__ == '__main__':
    main()
