import http.client
import logging
import json
import os

from common.aws.ssm.ssm import AwsSsm

class Auth0():
    AUTH0_CUSTOM_DOMAIN_KEY = 'AUTH0_CUSTOM_DOMAIN'
    AUTH0_CLIENT_ID_KEY = 'AUTH0_CLIENT_ID'
    AUTH0_CLIENT_SECRET_KEY = 'AUTH0_CLIENT_SECRET'
    AUTH0_AUDIENCE_PATTERN = 'https://{}/api/v2/'

    SPRYKER_AOP_AUTHENTICATION_KEY = 'SPRYKER_AOP_AUTHENTICATION'

    PARAM_STORE_AOP_AUTH0_CREDENTIALS_KEY = 'AOP_AUTH0_CREDENTIALS'

    AUTH0_APPS_PREFIX = 'apps_'
    AUTH0_TENANTS_PREFIX = 'tenants_'

    AUTH0_CONFIG_HOST_KEY = 'auth0_host'

    def __init__(self):
        self.credentials = {}
        self.jwt_token = ''
        self.auth0_domain = ''
        self.auth0_client_id = ''
        self.auth0_secret_key = ''
        self.auth0_audience = ''

    @classmethod
    def define_credentials(self, auth0_audience = ''):
        logging.info('[Auth0] Reading Auth0 credentials from the storage')

        credentials = AwsSsm.ssm_get_parameter(self.PARAM_STORE_AOP_AUTH0_CREDENTIALS_KEY, AwsSsm.PARAM_STORE_SECRET)

        if credentials is None or self.SPRYKER_AOP_AUTHENTICATION_KEY not in credentials['Parameter']['Value']:
            raise Exception('AOP_AUTH0_CREDENTIALS must be defined.')

        self.credentials = json.loads(credentials['Parameter']['Value'])[self.SPRYKER_AOP_AUTHENTICATION_KEY]
        self.auth0_domain = self.credentials[self.AUTH0_CUSTOM_DOMAIN_KEY]
        self.auth0_client_id = self.credentials[self.AUTH0_CLIENT_ID_KEY]
        self.auth0_secret_key = self.credentials[self.AUTH0_CLIENT_SECRET_KEY]

        self.auth0_audience = auth0_audience if auth0_audience else self.AUTH0_AUDIENCE_PATTERN.format(self.auth0_domain)

        logging.info(self.auth0_audience)

        logging.info('[Auth0] Obtained credentials: {}'.format(self.credentials))

        return self

    @classmethod
    def get_jwt_token(self):
        logging.info('[Auth0] Obtaining of JWT token from Auth0')
        conn = http.client.HTTPSConnection(self.auth0_domain)

        payload = "grant_type=client_credentials&client_id={}&client_secret={}&audience={}".format(self.auth0_client_id, self.auth0_secret_key, self.auth0_audience)
        logging.info('[Auth0] Payload {}'.format(payload))

        headers = { 'content-type': "application/x-www-form-urlencoded" }
        conn.request("POST", "/oauth/token", payload, headers)

        res = conn.getresponse()
        data = json.loads(res.read().decode("utf-8"))

        self.jwt_token = data['access_token']

        logging.info('[Auth0]  Obtained JWT token: {}'.format(self.jwt_token))

        return self.jwt_token

    @classmethod
    def get_env_client(self, jwt_token, prefix = ''):
        logging.info('[Auth0] Get clients')
        conn = http.client.HTTPSConnection(self.auth0_domain)

        headers = {
           "Content-Type": "application/json",
           "authorization": "Bearer {}".format(jwt_token)
        }

        conn.request("GET", "/api/v2/clients?fields=name,client_id,client_metadata,client_secret", headers=headers)

        res = conn.getresponse()
        clients = json.loads(res.read())

        return self.filter_clients_by_environment(clients, prefix)

    @staticmethod
    def filter_clients_by_environment(clients, prefix = ''):
        for client in clients:
            for key, value in client.items():
                if key == 'name' and value == prefix + os.environ['SPRYKER_PROJECT_NAME']:
                    return client

        return None

    @classmethod
    def get_client(self, jwt_token, client_id):
         logging.info('[Auth0] Get client')
         conn = http.client.HTTPSConnection(self.auth0_domain)

         headers = {
            "Content-Type": "application/json",
            "authorization": "Bearer {}".format(jwt_token)
         }

         conn.request("GET", "/api/v2/clients/{}".format(client_id), headers=headers)

         res = conn.getresponse()
         data = json.loads(res.read())

         logging.info('[Auth0] Get an existing client response data: {}'.format(data))

         return data

    @classmethod
    def create_client(self, jwt_token, tenants):
        logging.info('[Auth0] Create client')

        tenants_client_metadata = {}
        key = 0

        for tenant_key,tenant_data in tenants['tenants'].items():
            tenants_client_metadata.update({'store_reference_{}'.format(key) : tenant_data['storeReference']})
            key+=1

        conn = http.client.HTTPSConnection(self.auth0_domain)
        payload = {'name': self.AUTH0_TENANTS_PREFIX + os.environ['SPRYKER_PROJECT_NAME'], 'app_type': 'non_interactive', 'client_metadata': tenants_client_metadata}

        logging.info('[Auth0] Create client payload data {}'.format(payload))

        headers = {
            "Content-Type": "application/json",
            "authorization": "Bearer {}".format(jwt_token)
        }

        logging.info('Create client payload: {}'.format(payload))

        conn.request("POST", "/api/v2/clients", json.dumps(payload), headers)

        res = conn.getresponse()
        data = json.loads(res.read())
        logging.info('[Auth0] Create client response data {}'.format(data))

        grant_data = self.tenant_grant_permission(data['client_id'], jwt_token)
        payload.update({'client_id' : data['client_id'], "client_secret": data['client_secret']})
        tenants = tenants | payload

        logging.info('[Auth0] Created tenant: {}'.format(tenants))

        return tenants

    @classmethod
    def update_client(self, jwt_token, client, tenants = {}):
        logging.info('[Auth0] Update client')

        conn = http.client.HTTPSConnection(self.auth0_domain)

        tenants_client_metadata = {}
        client_data = {'client_id': client['client_id'], 'client_secret': client['client_secret']}
        key = len(client['client_metadata'])
        for tenant, tenant_data in tenants['tenants'].items():
            if tenant_data['storeReference'] not in client['client_metadata'].values():
                tenants_client_metadata.update({'store_reference_{}'.format(key) : tenant_data['storeReference']})
                key+=1


        logging.info('[Auth0] New tenants to update {}'.format(tenants_client_metadata))
        if not tenants_client_metadata:
            logging.info('[Auth0] Updated tenant: {}'.format(tenants))
            return tenants | client_data

        payload = {'client_metadata': client['client_metadata'] | tenants_client_metadata}
        logging.info('[Auth0] Update client payload: {}'.format(payload))

        headers = {
            "Content-Type": "application/json",
            "authorization": "Bearer {}".format(jwt_token)
        }
        conn.request("PATCH", "/api/v2/clients/{}".format(client['client_id']), json.dumps(payload), headers)

        res = conn.getresponse()
        data = json.loads(res.read())

        logging.info('[Auth0] Update client response data {}'.format(data))

        tenants = tenants | payload | client_data

        logging.info('[Auth0] Updated tenant: {}'.format(tenants))

        return tenants

    # AOP - tenant permission registration
    @classmethod
    def tenant_grant_permission(self, tenant_client_id, jwt_token):
        conn = http.client.HTTPSConnection(self.auth0_domain)

        headers = {
            "Content-Type": "application/json",
            "authorization": "Bearer {}".format(jwt_token)
        }

        payloads = [
            { "client_id": tenant_client_id, "audience": "aop-atrs", "scope": [ "read:app_atrs","configure:app_atrs" ] },
            { "client_id": tenant_client_id, "audience": "aop-app", "scope": [ "call:private_app" ] },
            { "client_id": tenant_client_id, "audience": "aop-event-platform", "scope": [ "event:app" ]}
        ]

        for payload in payloads:
            conn.request("POST", "/api/v2/client-grants", json.dumps(payload), headers)
            res = conn.getresponse()
            data = json.loads(res.read())

            logging.info('[Auth0] Update grant permission response data {}'.format(data))

        return data

    # AOP - tenant registration
    @classmethod
    def aop_register_tenants(self, jwt_token = '', tenants = {}):
        conn = http.client.HTTPSConnection(self.auth0_domain)

        tenants_client_metadata = {}
        data = {}

        client = self.get_env_client(jwt_token, self.AUTH0_TENANTS_PREFIX)

        if client is not None and 'client_id' in client:
            tenants = self.update_client(jwt_token, client, tenants)

            return tenants

        tenants = self.create_client(jwt_token, tenants)

        return tenants

    # AOP - application registration
    @classmethod
    def register_app(self, jwt_token, apps):

        logging.info('[Auth0] App registration')

        conn = http.client.HTTPSConnection(self.auth0_domain)

        # ToDo - Temporary added "break" after the first execution. Please remove it after the fix.
        for app_key, app_data in apps['apps'].items():
            client = self.get_env_client(jwt_token, self.AUTH0_APPS_PREFIX)
            if client:
                logging.info('[Auth0] App with the {} already registered'.format(client['client_id']))
                apps.update({'client_id' : client['client_id'], 'client_secret': client['client_secret']})
                continue
            payload = {"name": self.AUTH0_APPS_PREFIX + os.environ['SPRYKER_PROJECT_NAME'], 'app_type': 'non_interactive'}
            logging.info('[Auth0] App registration payload {}'.format(payload))
            headers = {
                "Content-Type": "application/json",
                "authorization": "Bearer {}".format(jwt_token)
            }
            conn.request("POST", "/api/v2/clients", json.dumps(payload), headers)

            res = conn.getresponse()
            data = json.loads(res.read())

            logging.info('[Auth0] App registration response data {}'.format(data))

            grant_data = self.app_grant_permission(data['client_id'], jwt_token)

#             apps['apps'][app_key].update(app_data | {'client_id' : data['client_id'], 'client_secret': data['client_secret']})
            apps.update({'client_id' : data['client_id'], 'client_secret': data['client_secret']})

            break

        return apps

    # AOP - application permission registration
    @classmethod
    def app_grant_permission(self, app_client_id, jwt_token):

        logging.info('[Auth0] App grant permission')

        conn = http.client.HTTPSConnection(self.auth0_domain)

        headers = {
            "Content-Type": "application/json",
            "authorization": "Bearer {}".format(jwt_token)
        }

        payloads = [
            {"client_id": app_client_id, "audience": "aop-event-platform", "scope": [ "event:app" ]},
        ]

        logging.info('[Auth0] App grant permission payload {}'.format(payloads))

        for payload in payloads:
            conn.request("POST", "/api/v2/client-grants", json.dumps(payload), headers)
            res = conn.getresponse()
            response_data = json.loads(res.read())

            logging.info('[Auth0] App grant permissions data {}'.format(response_data))

        return response_data

