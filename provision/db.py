#!/usr/bin/env python

import boto3
from botocore.exceptions import ClientError

import logging
import os
import yaml
import json
import string
import secrets

import mysql.connector
from mysql.connector import errors

PARAM_STORE_CODEBUILD = "codebuild/base_task_definition"
PARAM_STORE_SECRETS = "custom-secrets"
DEFAULT_DATABASE_KEY = "_default"

def ssm_get_parameter_path(parameter_store_path):
    return "/{}/{}/".format(os.environ['SPRYKER_PROJECT_NAME'], parameter_store_path)

def ssm_get_parameter(parameter_name, parameter_store_path = PARAM_STORE_CODEBUILD, with_decryption = True):
    """Get parameter details in AWS SSM

    :param parameter_name: Name of the parameter to fetch details from SSM
    :param with_decryption: return decrypted value for secured string params, ignored for String and StringList
    :return: Return parameter details if exist else None
    """
    ssm_client = boto3.client('ssm')

    try:
        result = ssm_client.get_parameter(
            Name=ssm_get_parameter_path(parameter_store_path) + parameter_name,
            WithDecryption=with_decryption
        )
    except ClientError as e:
        return None
    return result

def ssm_put_parameter(parameter_name, parameter_value, parameter_type, parameter_store_path = PARAM_STORE_CODEBUILD):
    """Creates new parameter in AWS SSM

    :param parameter_name: Name of the parameter to create in AWS SSM
    :param parameter_value: Value of the parameter to create in AWS SSM
    :param parameter_type: Type of the parameter to create in AWS SSM ('String'|'StringList'|'SecureString')
    :return: Return version of the parameter if successfully created else None
    """
    ssm_client = boto3.client('ssm')

    try:
        result = ssm_client.put_parameter(
            Name=ssm_get_parameter_path(parameter_store_path) + parameter_name,
            Value=parameter_value,
            Type=parameter_type,
            Overwrite=True
        )
    except ClientError as e:
        logging.error(e)
        return None
    return result['Version']

def ssm_delete_parameter(parameter_name, parameter_store_path):
    """Delete parameter in AWS SSM

    :param parameter_name: Name of the parameter to delete from AWS SSM
    """
    ssm_client = boto3.client('ssm')

    try:
        ssm_client.delete_parameter(
            Name=ssm_get_parameter_path(parameter_store_path) + parameter_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] != 'ParameterNotFound':
            logging.error(e)

def generate_pw(length = 20):
    """Generates random password. Contains letters + digits. The default length is 20 symbols"""

    alphabet = string.ascii_letters + string.digits
    password = '' . join(secrets.choice(alphabet) for i in range(length))

    return password

def read_deploy_file():
    with open("/provision/project.yml", "r") as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as e:
            logging.error(e)
            return None

def filter_by_store(data, stores):
    data_copy = tuple(data['databases'].keys())

    for key in data_copy:
        if key not in stores.keys(): del data['databases'][key]

    return data

def merge_two_dicts(x, y):
     z = x.copy()
     stores = {}

     for key, value in y['databases'].items():
         stores[key] = key
         if key in z['databases']:
            z['databases'][key]['database'] = y['databases'][key]['database']
            z['databases'][key]['username'] = y['databases'][key]['username']
            z['databases'][key]['character-set'] = y['databases'][key]['character-set']
            z['databases'][key]['collate'] = y['databases'][key]['collate']

            continue

         z['databases'][key] = value

     return filter_by_store(z, stores)

def read_database_configuration():
     deploy_file_data = read_deploy_file()

     db_host = ssm_get_parameter('SPRYKER_DB_HOST')
     db_port = ssm_get_parameter('SPRYKER_DB_PORT')

     data = {
        "version": "1.0",
        "databases": {},
     }

     data['databases']['_default'] = {
         'host': db_host['Parameter']['Value'],
         'port': db_port['Parameter']['Value'],
         'database': os.environ['SPRYKER_PROJECT_NAME'],
         'username': ssm_get_parameter('SPRYKER_DB_USERNAME')['Parameter']['Value'],
         'password': ssm_get_parameter('SPRYKER_DB_PASSWORD')['Parameter']['Value'],
         'character-set': 'utf8',
         'collate': 'utf8_general_ci'
     }

     is_valid_data = True
     for region_name, region_data in deploy_file_data['regions'].items():
        if 'database' in region_data['services']:
            ssm_put_parameter('SPRYKER_PAAS_SERVICES', json.dumps(data), 'SecureString', PARAM_STORE_SECRETS)
            exit(0)

        if 'databases' not in region_data['services'] or bool(region_data['services']['databases']) == False:
           print('Please check `region.services.databases` section for {} region'.format(region_name))
           break

        region_databases_data = region_data['services']['databases']

        for store_name, store_data in region_data['stores'].items():
            if 'services' in store_data and 'database' not in store_data['services']:
                is_valid_data = False
                print('Please check `region.stores.services.database` section for {} store.'.format(store_name))
                break

            data['databases'][store_name] = {}
            for service_data in store_data['services']:
                if service_data == 'database':
                    db_name = store_data['services']['database']['name']
                    if db_name not in region_databases_data:
                        is_valid_data = False
                        print('Please check `databases` section for {} region.'.format(region_name))
                        break
                    region_service_data = region_databases_data[db_name]
                    data['databases'][store_name] = {
                        'host': db_host['Parameter']['Value'],
                        'port': db_port['Parameter']['Value'],
                        'database': db_name,
                        'password': generate_pw(),
                        'username': 'spryker_' + db_name,
                        'character-set': 'utf8' if region_databases_data[db_name] == None or 'character-set' not in region_databases_data[db_name] else region_databases_data[db_name].get('character-set'),
                        'collate': 'utf8_general_ci' if region_databases_data[db_name] == None or 'collate' not in region_databases_data[db_name] else region_databases_data[db_name].get('collate')
                    }

     if is_valid_data == False or bool(data['databases']) == False:
        print('Deploy file has invalid data.')
        exit(1)

     paas_services = ssm_get_parameter('SPRYKER_PAAS_SERVICES', PARAM_STORE_SECRETS)

     if paas_services is None:
        return data

     paas_services_data = json.loads(paas_services['Parameter']['Value'])

     if bool(paas_services_data['databases']) == False:
        return data

     return merge_two_dicts(paas_services_data, data)

def provision_logical_dbs():
    """Creates logic dbs if they don't exist based on ${SPRYKER_PAAS_SERVICES} environment variable."""

    try:
        db_host = ssm_get_parameter('SPRYKER_DB_HOST')
        db_root_user_name = ssm_get_parameter('SPRYKER_DB_ROOT_USERNAME')
        db_root_password = ssm_get_parameter('SPRYKER_DB_ROOT_PASSWORD')

        mysql_connection = mysql.connector.connect(
          host=db_host['Parameter']['Value'],
          user=db_root_user_name['Parameter']['Value'],
          password=db_root_password['Parameter']['Value']
        )
        mysql_cursor = mysql_connection.cursor()

        data = read_database_configuration()

        if data is None or bool(data['databases']) == False:
            print('Please check your databases configuration.')
            exit(1)

        for key, db in data['databases'].items():
            if key == DEFAULT_DATABASE_KEY:
                continue

            db_database = db['database']
            db_username = db['username']
            db_password = db['password']
            db_character_set = db['character-set']
            db_collate = db['collate']

            print('Transaction started for `{}`.'.format(db_database))

            mysql_connection.start_transaction()

            db_create_query = "CREATE DATABASE IF NOT EXISTS `{}` CHARACTER SET `{}` COLLATE `{}`;".format(db_database,  db_character_set, db_collate)
            db_create_user_query = "CREATE USER IF NOT EXISTS `{}`@`%` IDENTIFIED BY '{}'".format(db_username, db_password)
            db_alter_user_credentials = "ALTER USER `{}`@`%` IDENTIFIED BY '{}';".format(db_username, db_password)
            db_grant_permission_query = "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `{}`.* TO `{}`@'%' IDENTIFIED BY '{}';".format(db_database, db_username, db_password)
            db_flush_privileges_query = "FLUSH PRIVILEGES;"
            mysql_cursor.execute(db_create_query)
            mysql_cursor.execute(db_create_user_query)
            mysql_cursor.execute(db_alter_user_credentials)
            mysql_cursor.execute(db_grant_permission_query)
            mysql_cursor.execute(db_flush_privileges_query)

            mysql_connection.commit()
            print('Transaction committed for `{}`.'.format(db_database))

        ssm_put_parameter('SPRYKER_PAAS_SERVICES', json.dumps(data), 'SecureString', PARAM_STORE_SECRETS)

    except errors.Error as e:
        mysql_connection.rollback()
        print("Rolling back ...")
        print(e)
        exit(1)

    finally:
        mysql_cursor.close()
        mysql_connection.close()

def main():
    provision_logical_dbs()
    exit(0)

if __name__ == '__main__':
    main()
