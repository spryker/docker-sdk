from atrs.atrs import Atrs
from tenant.tenant import Tenant
from app.app import App

import logging

logging.basicConfig(level=logging.INFO)

def main():
    try:
        apps, configs = App.get_apps()
        Atrs.define_atrs_host(configs[Atrs.ATRS_HOST_KEY])

### Apps registration

        if apps:
            apps = App.register_apps(apps, configs)
            logging.info('Apps list: {}'.format(apps))

### Tenants registration
        if apps == None:
            tenants = Tenant.get_tenants()

            if tenants != {}:
                tenants = Tenant.register_tenants(tenants, configs)
                logging.info('Tenants list: {}'.format(tenants))

    except Exception as e:
        logging.info(e)
        exit(1)

    exit(0)

if __name__ == '__main__':
    main()
