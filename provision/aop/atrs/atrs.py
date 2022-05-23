import http.client
import os
import logging
import json
import glob
from pathlib import Path

from auth0.auth0 import Auth0
from config.config import Config

class Atrs:
    _atrs_host = ''

    def __init__(self):
        logging.info('[AOP] AOP constructor')

    @classmethod
    def define_atrs_host(self, configs):
        if Config.ATRS_HOST_KEY not in configs:
            raise Exception('[AOP] Atrs host is not defined.')

        self._atrs_host = configs[Config.ATRS_HOST_KEY]

    @classmethod
    def infrastructure_registration(self, jwt_token, aops, aops_key):
        logging.info('[AOP] Infrastructure registration')
        conn = http.client.HTTPSConnection(self._atrs_host)

        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token),
            "Content-Type": "application/json"
        }

        for aop_key,aop_data in aops[aops_key].items():
            logging.info('[AOP] Infrastructure registration payload {}'.format(aop_data))
            conn.request("POST", "/aop-infrastructure-registration", json.dumps(aop_data), headers)
            res = conn.getresponse()
            logging.info('[AOP] Infrastructure registration status code {}'.format(res.status))
            if res.status != 200 and res.status != 204:
                data = json.loads(res.read())
                logging.info('[AOP] App registration error {}'. format(json.dumps(data)))
                raise Exception('Cannot register tenant {}'.format(aop_key))
            conn.close()

        return aops

    @classmethod
    def tenant_registration(self, jwt_token, tenants, applications, configs):
        logging.info('[AOP] Infrastructure. Tenant registration')
        conn = http.client.HTTPSConnection(self._atrs_host)

        Auth0.define_credentials(configs)
        auth0_jwt_token = Auth0.get_jwt_token()
        client = Auth0.get_env_client(auth0_jwt_token, Auth0.AUTH0_TENANTS_PREFIX)

        if client is None:
            raise Exception('[AOP] Infrastructure exception. Tenant Auth0 application doesn\'t exist')

        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token),
            "Content-Type": "application/json"
        }

        for tenant_key,tenant_data in tenants['tenants'].items():
            payload_data = {
                "data": {
                    "type": "tenants",
                    "attributes": {
                      "tenantId": tenant_data['storeReference'],
                      "environmentName": os.environ['SPRYKER_PROJECT_NAME'],
                      "environmentType": 'development',
                      "applications": applications[tenant_key.upper()],
                      "organizationId": os.environ['SPRYKER_PROJECT_NAME'],
                      "aopClientId": client['client_id'],
                    }
                }
            }

            logging.info('[AOP] Tenant registration payload {}'.format(payload_data))
            conn.request("POST", "/tenants", json.dumps(payload_data), headers)
            res = conn.getresponse()
            logging.info('[AOP] Tenant registration status {}'.format(res.status))

            if res.status != 200 and res.status != 204:
                data = json.loads(res.read())
                if data['errors'][0]['code'] != "910":
                    logging.info('[AOP] Tenant registration error {}'. format(json.dumps(data)))
                    raise Exception('Cannot register tenant {}'.format(tenant_key))
                logging.info('[AOP] Tenant "{}" already registered'. format(tenant_data['storeReference']))
            conn.close()

        return tenants

    @classmethod
    def app_registration(self, jwt_token, apps):
        logging.info('[AOP] Infrastructure. Apps registration')

        conn = http.client.HTTPSConnection(self._atrs_host)

        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token),
            "Content-Type": "application/json"
        }

        for app_key, app_data in apps['apps'].items():
            if type(app_data) is not dict:
                logging.info('[AOP] Temporary skipping {}'.format(app_data))
                continue

            for attribute_key, attribute_data in app_data.items():
                if attribute_key == 'appId':
                    continue

                payload_data = {
                    "data": {
                        "type": "apps",
                        "attributes": {
                            "id": app_data['appId']
                        }
                    }
                }
                tmp_data = {}
                for filename in glob.iglob('app/{}'.format(attribute_data) + '**/**', recursive=True):
                     if os.path.isfile(filename):
                        file_name= Path(filename).stem
                        file_extension = os.path.splitext(filename)[1]
                        if file_extension == '.json':
                            file_content = json.load(open(filename))
                            if 'manifest' in filename:
                                if 'manifest' not in payload_data['data']['attributes']:
                                    payload_data['data']['attributes'].update({'manifest': {}})
                                tmp_data = tmp_data | {file_name: file_content}
                                file_content = tmp_data
                                file_name = 'manifest'

                            payload_data['data']['attributes'].update({file_name: json.dumps(file_content)})

            logging.info('[AOP] App registration, payload data {}'.format(payload_data))
            conn.request("POST", "/apps", json.dumps(payload_data), headers)
            res = conn.getresponse()
            logging.info('[AOP] App registration, status {}'.format(res.status))

            if res.status != 200 and res.status != 204:
               data = json.loads(res.read())
               if data['errors'][0]['code'] != "910":
                   logging.info('[AOP] App registration error {}'. format(json.dumps(data)))
                   raise Exception('[AOP] Cannot register App {}'.format(app_key))
               logging.info('[AOP] Tenant "{}" already registered'. format(app_data['appId']))
            conn.close()

            logging.info('[AOP] Infrastructure. Apps registration has been finished')

        return apps
