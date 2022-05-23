import logging
import json
import os
import sys
sys.path.insert(1, os.getcwd())
from common.aws.ssm.ssm import AwsSsm
from common.yml.yml import YamlParser

class Config:
    CONFIGS_KEY = 'configs'
    DEFAULT_CONFIG_KEY = 'staging'
    ENVIRONMENT_TYPE_KEY = 'environment'

    ATRS_HOST_KEY = 'atrs_host'

    AUTH0_HOST_KEY = 'auth0_host'
    AUTH0_CLIENT_ID_KEY = 'auth0_client_id'
    AUTH0_CLIENT_SECRET_KEY = 'auth0_client_secret'

    ACCOUNT_ID_KEY = 'account_id'
    REGION_KEY = 'region'

    WEBHOOK_URL = 'webhook_url'

    def __init__(self):
        logging.info('[AOP Config] Config constructor')

    @classmethod
    def get_configs(self, config_path):
        logging.info('[AOP Config] Configuration reader')

        configs = AwsSsm.ssm_get_parameter('AOP_CONFIGURATION', AwsSsm.PARAM_STORE_SECRET)

        if configs is None:
            logging.exception('[AOP Config] Please check `AOP_CONFIGURATION` and try again')

        aop_configs = YamlParser.parse(config_path)
        configs = json.loads(configs["Parameter"]["Value"])

        config_condition = aop_configs is not None and self.CONFIGS_KEY in aop_configs and self.ENVIRONMENT_TYPE_KEY in aop_configs[self.CONFIGS_KEY]

        if config_condition and aop_configs[self.CONFIGS_KEY][self.ENVIRONMENT_TYPE_KEY] not in configs:
            raise Exception('[AOP Config] Please check your environment type name from aop.yml. As "{}" type doesn\'t exist.'.format(aop_configs[self.CONFIGS_KEY][self.ENVIRONMENT_TYPE_KEY]))

        config_environment = self.DEFAULT_CONFIG_KEY if not config_condition else aop_configs[self.CONFIGS_KEY][self.ENVIRONMENT_TYPE_KEY]

        if aop_configs is not None and self.CONFIGS_KEY in aop_configs:
            configs = configs[config_environment] | aop_configs[self.CONFIGS_KEY]
        else:
            configs = configs[config_environment] | {self.ENVIRONMENT_TYPE_KEY: self.DEFAULT_CONFIG_KEY }

        self.update_webhook_url(configs)

        return configs

    @classmethod
    def update_webhook_url(self, configs):
        if self.WEBHOOK_URL in configs:
            AwsSsm.ssm_put_parameter('PARAMETER_STORE_SLACK_WH_URL', configs[self.WEBHOOK_URL], 'SecureString')

