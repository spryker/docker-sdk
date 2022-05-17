from subscription.subscription import Subscription
from auth0.auth0 import Auth0
from yml.yml import YamlParser
from atrs.atrs import Atrs
from env.env import Env

import os
import logging

class App:
    APPS_CONFIGURATION_FILE = 'aop.yml'
    APPS_KEY = 'apps'
    APP_ID_KEY = 'appId'
    CONFIGS_KEY = 'configs'

    @classmethod
    def get_apps(self):
        logging.info('[APP] Reading and prepare the list of registered apps')
        apps_data = YamlParser.parse(self.APPS_CONFIGURATION_FILE)

        configs = None if self.CONFIGS_KEY not in apps_data else apps_data[self.CONFIGS_KEY]

        if self.APPS_KEY not in apps_data or apps_data is None:
            return None, configs

        apps = {
            self.APPS_KEY: {}
        }
        for app_key, app_data in apps_data[self.APPS_KEY].items():
            app_key_lower = app_key.lower()
            app_unique_key = app_key_lower + '_' + os.environ['SPRYKER_PROJECT_NAME']
            apps[self.APPS_KEY].update({app_key_lower:{}})
            apps[self.APPS_KEY][app_key_lower].update(app_data | {self.APP_ID_KEY: app_unique_key })

        logging.info('[APP] The list of registered app: {}'.format(apps))

        return apps, configs

    @classmethod
    def register_apps(self, apps, configs):
        logging.info('[APP] Apps registration process has been started')

        Auth0.define_credentials()
        jwt_token = Auth0.get_jwt_token()
        apps = Auth0.register_app(jwt_token, apps)
        apps = Subscription.aop_register_queue(apps, self.APPS_KEY, self.APP_ID_KEY)
        Atrs.define_atrs_host(configs[Atrs.ATRS_HOST_KEY])

        Auth0.define_credentials(Auth0.AUTH0_AOP_EVENT_PLATFORM)
        jwt_token = Auth0.get_jwt_token()
        apps = Atrs.infrastructure_registration(jwt_token, apps, self.APPS_KEY)
        Subscription.sqs_sns_subscription(apps[self.APPS_KEY], self.APP_ID_KEY)
        Env.define_app_environment_vars(apps, configs)

        logging.info('[APP] Apps registration process has been finished successfully')

        return apps
