#!/usr/bin/env python

import logging
import os
import json
import string
import secrets

import mysql.connector
from mysql.connector import errors

class MultiDb:

    DEFAULT_DATABASE_KEY = "_default"

    def __init__(self):
        logging.info('[MultiDB] Constructor')

    @classmethod
    def provision_logical_dbs(self, yaml_parser, aws_ssm):
        """Creates logic dbs if they don't exist based on ${SPRYKER_PAAS_SERVICES} environment variable."""
        try:
            logging.info('[MultiDB] Provision logical dbs')

            data = self.read_database_configuration(yaml_parser, aws_ssm)

            if data is None or bool(data['databases']) == False:
                logging.info('[MultiDB] Please check your databases configuration.')
                exit(1)

            db_host = aws_ssm.ssm_get_parameter('SPRYKER_DB_HOST', aws_ssm.PARAM_STORE_CODEBUILD)
            db_root_user_name = aws_ssm.ssm_get_parameter('SPRYKER_DB_ROOT_USERNAME', aws_ssm.PARAM_STORE_CODEBUILD)
            db_root_password = aws_ssm.ssm_get_parameter('SPRYKER_DB_ROOT_PASSWORD', aws_ssm.PARAM_STORE_CODEBUILD)

            mysql_connection = mysql.connector.connect(
              host=db_host['Parameter']['Value'],
              user=db_root_user_name['Parameter']['Value'],
              password=db_root_password['Parameter']['Value']
            )
            mysql_cursor = mysql_connection.cursor()

            for key, db in data['databases'].items():
                if key == self.DEFAULT_DATABASE_KEY:
                    continue

                db_database = db['database']
                db_username = db['username']
                db_password = db['password']
                db_character_set = db['character-set']
                db_collate = db['collate']

                logging.info('[MultiDB] Transaction started for `{}`.'.format(db_database))

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
                logging.info('[MultiDB] Transaction committed for `{}`.'.format(db_database))

            aws_ssm.ssm_put_parameter('SPRYKER_PAAS_SERVICES', json.dumps(data), aws_ssm.PARAM_STORE_SECURE_STRING_TYPE, aws_ssm.PARAM_STORE_SECRET)

        except Exception as e:
            logging.info('[MultiDB] Rolling back due to {}'.format(e))
            mysql_connection.rollback()
            exit(1)

        finally:
            logging.info('[MultiDB] Closing DB connection')
            mysql_cursor.close()
            mysql_connection.close()
            exit(0)

    @classmethod
    def read_database_configuration(self, yaml_parser, aws_ssm):
         try:
             logging.info('[MultiDB] Reading and validate deploy file configuration')

             deploy_file_data = yaml_parser.get_deploy_file_data()
             db_host = aws_ssm.ssm_get_parameter('SPRYKER_DB_HOST', aws_ssm.PARAM_STORE_CODEBUILD)
             db_port = aws_ssm.ssm_get_parameter('SPRYKER_DB_PORT', aws_ssm.PARAM_STORE_CODEBUILD)
             db_username = aws_ssm.ssm_get_parameter('SPRYKER_DB_USERNAME', aws_ssm.PARAM_STORE_CODEBUILD)
             db_username = aws_ssm.ssm_get_parameter('SPRYKER_DB_PASSWORD', aws_ssm.PARAM_STORE_CODEBUILD)

             data = {
                "version": "1.0",
                "databases": {},
             }

             data['databases']['_default'] = {
                 'host': db_host['Parameter']['Value'],
                 'port': db_port['Parameter']['Value'],
                 'database': os.environ['SPRYKER_PROJECT_NAME'],
                 'username': db_username['Parameter']['Value'],
                 'password': db_username['Parameter']['Value'],
                 'character-set': 'utf8',
                 'collate': 'utf8_general_ci'
             }

             is_valid_data = True
             for region_name, region_data in deploy_file_data['regions'].items():
                if 'database' in region_data['services']:
                    logging.info('[MultiDB] Databases section is not defined')
                    aws_ssm.ssm_put_parameter('SPRYKER_PAAS_SERVICES', json.dumps(data), aws_ssm.PARAM_STORE_SECURE_STRING_TYPE, aws_ssm.PARAM_STORE_SECRET)
                    exit(0)

                if 'databases' not in region_data['services'] or bool(region_data['services']['databases']) == False:
                   logging.info('[MultiDB] Please check `region.services.databases` section for {} region'.format(region_name))
                   break

                region_databases_data = region_data['services']['databases']
                for store_name, store_data in region_data['stores'].items():
                    if 'services' in store_data and 'database' not in store_data['services']:
                        is_valid_data = False
                        logging.info('[MultiDB] Please check `region.stores.services.database` section for {} store.'.format(store_name))
                        break

                    data['databases'][store_name] = {}
                    for service_data in store_data['services']:
                        if service_data == 'database':
                            db_name = store_data['services']['database']['name']
                            if db_name not in region_databases_data:
                                is_valid_data = False
                                logging.info('[MultiDB] Please check `databases` section for {} region.'.format(region_name))
                                break
                            region_service_data = region_databases_data[db_name]
                            data['databases'][store_name] = {
                                'host': db_host['Parameter']['Value'],
                                'port': db_port['Parameter']['Value'],
                                'database': db_name,
                                'password': self.generate_pw(),
                                'username': 'spryker_' + db_name,
                                'character-set': 'utf8' if region_databases_data[db_name] == None or 'character-set' not in region_databases_data[db_name] else region_databases_data[db_name].get('character-set'),
                                'collate': 'utf8_general_ci' if region_databases_data[db_name] == None or 'collate' not in region_databases_data[db_name] else region_databases_data[db_name].get('collate')
                            }

             if is_valid_data == False or bool(data['databases']) == False:
                logging.info('[MultiDB] Deploy file has invalid data.')
                exit(1)

             paas_services = aws_ssm.ssm_get_parameter('SPRYKER_PAAS_SERVICES', aws_ssm.PARAM_STORE_SECRET)

             if paas_services is None:
                return data

             paas_services_data = json.loads(paas_services['Parameter']['Value'])

             if bool(paas_services_data['databases']) == False:
                return data

             return self.merge_two_dicts(paas_services_data, data)
         except Exception as e:
            logging.exception(e)
            raise

    @classmethod
    def merge_two_dicts(self, x, y):
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

         return self.filter_by_store(z, stores)

    @staticmethod
    def filter_by_store(data, stores):
        data_copy = tuple(data['databases'].keys())

        for key in data_copy:
            if key not in stores.keys(): del data['databases'][key]

        return data

    @staticmethod
    def generate_pw(length = 20):
        """Generates random password. Contains letters + digits. The default length is 20 symbols"""

        alphabet = string.ascii_letters + string.digits
        password = '' . join(secrets.choice(alphabet) for i in range(length))

        return password
