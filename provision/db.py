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

def ssm_get_parameter_path():
    return "/{}/codebuild/base_task_definition/".format(os.environ['PROJECT_NAME'])

def ssm_get_parameter(parameter_name, with_decryption = True):
    """Get parameter details in AWS SSM

    :param parameter_name: Name of the parameter to fetch details from SSM
    :param with_decryption: return decrypted value for secured string params, ignored for String and StringList
    :return: Return parameter details if exist else None
    """
    ssm_client = boto3.client('ssm',
        aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
        region_name=os.environ['AWS_DEFAULT_REGION']
    )

    try:
        result = ssm_client.get_parameter(
            Name=ssm_get_parameter_path() + parameter_name,
            WithDecryption=with_decryption
        )
    except ClientError as e:
        return None
    return result

def ssm_put_parameter(parameter_name, parameter_value, parameter_type):
    """Creates new parameter in AWS SSM

    :param parameter_name: Name of the parameter to create in AWS SSM
    :param parameter_value: Value of the parameter to create in AWS SSM
    :param parameter_type: Type of the parameter to create in AWS SSM ('String'|'StringList'|'SecureString')
    :return: Return version of the parameter if successfully created else None
    """
    ssm_client = boto3.client('ssm',
        aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
        region_name=os.environ['AWS_DEFAULT_REGION']
    )

    try:
        result = ssm_client.put_parameter(
            Name=ssm_get_parameter_path() + parameter_name,
            Value=parameter_value,
            Type=parameter_type,
            Overwrite=True
        )
    except ClientError as e:
        logging.error(e)
        return None
    return result['Version']

def ssm_delete_parameter(parameter_name):
    """Delete parameter in AWS SSM

    :param parameter_name: Name of the parameter to delete from AWS SSM
    """
    ssm_client = boto3.client('ssm')

    try:
        ssm_client.delete_parameter(
            Name=ssm_get_parameter_path() + parameter_name
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
    with open("deploy.{}.yml".format(os.environ['PROJECT_NAME']), "r") as stream:
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
            z['databases'][key]['character-set'] = y['databases'][key]['character-set']
            z['databases'][key]['collate'] = y['databases'][key]['collate']

            continue

         z['databases'][key] = value

     return filter_by_store(z, stores)

def read_database_configuration():
     deploy_file_data = read_deploy_file()
     data = {
        "version": "1.0",
        "databases": {},
     }
     is_valid_data = True
     for region_name, region_data in deploy_file_data['regions'].items():
        if 'database' in region_data['services']:
            return None

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
                        'database': db_name,
                        'password': generate_pw(),
                        'username': 'spryker-' + db_name,
                        'character-set': 'utf8' if region_databases_data[db_name] == None else region_databases_data[db_name].get('character-set'),
                        'collate': 'utf8_general_ci' if region_databases_data[db_name] == None else region_databases_data[db_name].get('collate')
                    }

     db_paas = ssm_get_parameter('SPRYKER_DB_PAAS')

     if is_valid_data == False or bool(data['databases']) == False:
        data['databases'] = {}

        return data

     if db_paas is None:
        return data

     db_paas_data = json.loads(db_paas['Parameter']['Value'])

     return merge_two_dicts(db_paas_data, data)

def provision_logical_dbs():
    """Creates logic dbs if they don't exist based on ${SPRYKER_DB_PAAS} environment variable."""

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

        if data is None:
            ssm_delete_parameter('SPRYKER_DB_PAAS')

            return

        if bool(data['databases']) == False:
            return

        databases = []
        mysql_cursor.execute("SHOW DATABASES")
        for database in mysql_cursor:
            databases.append(database[0])

        for key, db in data['databases'].items():
            db_database = db['database']

            if db_database in databases:
                print('Database `{}` already exist.'.format(db_database))
                continue

            db_character_set = db['character-set']
            db_collate = db['collate']
            db_username = 'spryker-' + db_database
            db_password = db['password']

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

        ssm_put_parameter('SPRYKER_DB_PAAS', json.dumps(data), 'String')

    except errors.Error as e:
        mysql_connection.rollback()
        print("Rolling back ...")
        print(e)

    finally:
        mysql_cursor.close()
        mysql_connection.close()

def main():
    provision_logical_dbs()

if __name__ == '__main__':
    main()




