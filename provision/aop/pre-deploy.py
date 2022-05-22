from atrs.atrs import Atrs
from tenant.tenant import Tenant
from config.config import Config
from app.app import App
import logging

logging.basicConfig(level=logging.INFO)

def main():
    try:
        logging.info('[PRE-DEPLOY] Reading configuration')
        configs = Config.get_configs(App.APPS_CONFIGURATION_FILE)
        Atrs.define_atrs_host(configs)

        apps = App.get_apps()
        if apps:
            logging.info('[PRE-DEPLOY] Apps registration')
            apps = App.register_apps(apps, configs)
            logging.info('[PRE-DEPLOY] Apps list: {}'.format(apps))

        if apps == None:
            logging.info('[PRE-DEPLOY] Tenants registration')
            tenants = Tenant.get_tenants()

            if tenants != {}:
                tenants = Tenant.register_tenants(tenants, configs)
                logging.info('[PRE-DEPLOY] Tenants list: {}'.format(tenants))

    except Exception as e:
        logging.info(e)
        exit(1)

    exit(0)

if __name__ == '__main__':
    main()
