from yml.yml import YamlParser
from auth0.auth0 import Auth0
from atrs.atrs import Atrs
from tenant.tenant import Tenant
from app.app import App

import logging

logging.basicConfig(level=logging.INFO)

def main():
    try:
      Auth0.define_credentials(Auth0.AUTH0_AOP_EVENT_PLATFORM)
      auth0_jwt_token = Auth0.get_jwt_token()

      apps, configs = App.get_apps()
      Atrs.define_atrs_host(configs[Atrs.ATRS_HOST_KEY])

### Apps registration
      if apps:
          apps = Atrs.app_registration(auth0_jwt_token, apps)

### Tenants registration
      if apps is None or apps == {}:
          tenants = Tenant.get_tenants()
          applications = YamlParser.get_applications()
          tenants = Atrs.tenant_registration(auth0_jwt_token, tenants, applications)

    except Exception as e:
      logging.error(str(e))
      exit(1)

    exit(0)

if __name__ == '__main__':
    main()
