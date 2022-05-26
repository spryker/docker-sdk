from auth0.auth0 import Auth0
from atrs.atrs import Atrs
from tenant.tenant import Tenant
from app.app import App
from config.config import Config
import logging, sys
sys.path.append("..")
from common.yml.yml import YamlParser

logging.basicConfig(level=logging.INFO)

def main():
    try:
      logging.info('[PRE-DEPLOY] Reading configuration')
      configs = Config.get_configs(App.APPS_CONFIGURATION_FILE)
      Atrs.define_atrs_host(configs)

      Auth0.define_credentials(configs, Auth0.AUTH0_AOP_ATRS)
      auth0_jwt_token = Auth0.get_jwt_token()

      apps = App.get_apps()
      if apps:
          logging.info('[POST-DEPLOY] Apps registration')
          apps = Atrs.app_registration(auth0_jwt_token, apps, configs)
          logging.info('[POST-DEPLOY] Apps registration "{}" has been finished successfully'.format(apps))

      if apps is None or apps == {}:
          logging.info('[POST-DEPLOY] Tenants registration')
          tenants = Tenant.get_tenants()
          applications = YamlParser.get_applications()
          tenants = Atrs.tenant_registration(auth0_jwt_token, tenants, applications, configs)
          logging.info('[POST-DEPLOY] Tenants registration "{}" has been finished successfully'.format(tenants))

    except Exception as e:
      logging.error(str(e))
      exit(1)

    exit(0)

if __name__ == '__main__':
    main()
