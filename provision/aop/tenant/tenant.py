from subscription.subscription import Subscription
from auth0.auth0 import Auth0
from yml.yml import YamlParser
from atrs.atrs import Atrs
from env.env import Env

import os
import logging

class Tenant:

    TENANTS_KEY = 'tenants'
    STORE_REFERENCE_KEY = 'storeReference'

    @classmethod
    def get_tenants(self):
        logging.info('[Tenant] Get list of tenants based on deploy file')
        deploy_file_data = YamlParser.get_deploy_file_data()

        tenants = {
            self.TENANTS_KEY : {}
        }

        for region_name, region_data in deploy_file_data['regions'].items():
            for store_name in region_data['stores']:
                tenant_name = store_name.lower()
                store_reference = tenant_name + '_' + os.environ['SPRYKER_PROJECT_NAME'].lower()
                tenants[self.TENANTS_KEY].update({tenant_name: {'storeReference': store_reference}})

        logging.info('[Tenant] Tenants list: {}'.format(tenants))

        return tenants

    @classmethod
    def register_tenants(self, tenants, configs):
        logging.info('[Tenant] Tenants initialization has been started')

        Auth0.define_credentials()
        jwt_token = Auth0.get_jwt_token()
        tenants = Auth0.aop_register_tenants(jwt_token, tenants)
        tenants = Subscription.aop_register_queue(tenants, self.TENANTS_KEY, self.STORE_REFERENCE_KEY)
        tenants = Atrs.infrastructure_registration(jwt_token, tenants, self.TENANTS_KEY)
        Subscription.sqs_sns_subscription(tenants[self.TENANTS_KEY], self.STORE_REFERENCE_KEY)
        Env.define_tenant_environment_vars(tenants, configs)

        logging.info('[Tenant] Tenants initialization have been finished')

        return tenants
