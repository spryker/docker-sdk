import http.client
import os
import logging
import json

from auth0.auth0 import Auth0

class Atrs:
    ATRS_HOST_KEY = 'atrs_host'

    _atrs_host = ''

    def __init__(self):
        logging.info('[AOP] AOP constructor')

    @classmethod
    def define_atrs_host(self, atrs_host):
        self._atrs_host = atrs_host

    @classmethod
    def infrastructure_registration(self, jwt_token, aops, aops_key):
        logging.info('[AOP] Infrastructure registration')
        conn = http.client.HTTPSConnection(self._atrs_host)

        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token)
        }

        for aop_key,aop_data in aops[aops_key].items():
            logging.info('[AOP] Infrastructure registration payload {}'.format(aop_data))
            conn.request("POST", "/aop-infrastructure-registration", json.dumps(aop_data), headers)
            res = conn.getresponse()
            logging.info('[AOP] Infrastructure registration status code {}'.format(res.status))
#             if res.status != 204:
#                 raise Exception('Cannot register tenant {}'.format(aop_key))
            conn.close()

        return aops

    @classmethod
    def get_tenant(self, jwt_token, storeReference):
        logging.info('[AOP] Infrastructure. Check for registered tenant')

        conn = http.client.HTTPSConnection(self._atrs_host)
        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token)
        }

        conn.request("GET", "/tenants/{}".format(storeReference), headers=headers)

        res = conn.getresponse()

        data = json.loads(res.read())

        return False

    @classmethod
    def tenant_registration(self, jwt_token, tenants, applications):
        logging.info('[AOP] Infrastructure. Tenant registration')
        conn = http.client.HTTPSConnection(self._atrs_host)

        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token)
        }

        client = Auth0.get_env_client(jwt_token, Auth0.AUTH0_TENANTS_PREFIX)

        if client is None:
            raise Exception('[AOP] Infrastructure exception. Tenant Auth0 application doesn\'t exist')

        for tenant_key,tenant_data in tenants['tenants'].items():
            is_tenant_registered = self.get_tenant(jwt_token, tenant_data['storeReference'])
            if is_tenant_registered == True:
                logging.info('[AOP] An infrastructure already registered for "{}" tenant'.format(tenant_key))
                continue

            payload_data = {
                "data": {
                    "type": "tenant",
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
#             if r.status != 204:
#                 raise Exception('Cannot register tenant {}'.format(tenant_key))
            conn.close()

        return tenants

    @classmethod
    def get_app(self, jwt_token, appId):
        logging.info('[AOP] Infrastructure. App existence check')
        conn = http.client.HTTPSConnection(self._atrs_host)
        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token)
        }

        conn.request("GET", "/apps/{}".format(appId), headers=headers)

        res = conn.getresponse()

        logging.info('[AOP] App check status {}'.format(res.status))

        data = json.loads(res.read())

        logging.info('[AOP] Infrastructure. App existence status "{}"'.format('False'))

        return False

    @classmethod
    def app_registration(self, jwt_token, apps):
        logging.info('[AOP] Infrastructure. Apps registration')

        conn = http.client.HTTPSConnection(self._atrs_host)

        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {}".format(jwt_token)
        }

        payload_data = {
            "data": {
                "type": "apps",
                "attributes": {}
            }
        }

        for app_key, app_data in apps['apps'].items():
            is_app_registered = self.get_app(jwt_token, app_data['appId'])
            if is_app_registered:
                logging.info('[AOP] An infrastructure already registered for "{}" tenant'.format(app_key))
                continue

            if type(app_data) is not dict:
                logging.info('[AOP] Temporary skipping {}'.format(app_data))
                continue
            for attribute_key, attribute_data in app_data.items():
                if attribute_key == 'appId':
                    continue
                f = open(attribute_data)
                payload_data['data']['attributes'].update({
                    attribute_key: json.load(f)
                })

            logging.info('[AOP] App registration, payload data {}'.format(payload_data))

        conn.request("POST", "/apps", json.dumps(payload_data), headers)
        res = conn.getresponse()
        logging.info('[AOP] App registration, status {}'.format(res.status))
#         if res.status != 204:
#            raise Exception('Cannot register tenant {}'.format(tenant_key))
        conn.close()

        logging.info('[AOP] Infrastructure. Apps registration has been finished')

        return apps
