<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSdk;

/**
 * Class was created automatically on docker/sdk boot step.
 * For any updates go to `generateDockerSdkConstantsPhpFile()` into index.php
 */
interface DockerSdkConstants
{
    /**
     * @var string
     */
    public const DOCKER_COMPOSE_FILENAME = 'docker-compose.yml';
    /**
     * @var string
     */
    public const DOCKER_COMPOSE_GATEWAY_DATA_FILENAME = 'docker-compose-gateway-data.json';
    /**
     * @var string
     */
    public const DOCKER_COMPOSE_PROJECTS_DATA_FILENAME = 'docker-compose-projects-data.json';
    /**
     * @var string
     */
    public const DOCKER_COMPOSE_REDIS_DATA_FILENAME = 'docker-compose-redis-data.json';
    /**
     * @var string
     */
    public const DOCKER_COMPOSE_SHARED_SERVICES_DATA_FILENAME = 'docker-compose-shared-services-data.json';
    /**
     * @var string
     */
    public const DOCKER_COMPOSE_SYNC_DATA_FILENAME = 'docker-compose-sync-data.json';
    /**
     * @var string
     */
    public const ENABLED_FILENAME = 'enabled';
    /**
     * @var string
     */
    public const GATEWAY_HOSTS_KEY = 'hosts';
    /**
     * @var string
     */
    public const GATEWAY_PORTS_KEY = 'ports';
    /**
     * @var string
     */
    public const MUTAGEN_DATA_PROJECTS_KEY = 'projects';
    /**
     * @var string
     */
    public const MUTAGEN_DATA_PROJECT_NAME_KEY = 'project_name';
    /**
     * @var string
     */
    public const MUTAGEN_DATA_PROJECT_PATH_KEY = 'project_path';
    /**
     * @var string
     */
    public const MUTAGEN_DATA_SYNC_IGNORE_KEY = 'sync_ignore';
    /**
     * @var string
     */
    public const PROJECT_DATA_DEBUG_MODE_ENABLED_KEY = '_debug_mode_enabled';
    /**
     * @var string
     */
    public const PROJECT_DATA_DEPLOYMENT_PATH_KEY = 'deployment_path';
    /**
     * @var string
     */
    public const PROJECT_DATA_DOCKER_DEBUG_KEY = 'debug';
    /**
     * @var string
     */
    public const PROJECT_DATA_DOCKER_DEBUG_XDEBUG_ENABLED_KEY = 'enabled';
    /**
     * @var string
     */
    public const PROJECT_DATA_DOCKER_DEBUG_XDEBUG_KEY = 'xdebug';
    /**
     * @var string
     */
    public const PROJECT_DATA_DOCKER_KEY = 'docker';
    /**
     * @var string
     */
    public const PROJECT_DATA_GROUPS_APPLICATIONS_APPLICATION_DEPLOYMENT_PATH_KEY = 'deployment_path';
    /**
     * @var string
     */
    public const PROJECT_DATA_GROUPS_APPLICATIONS_APPLICATION_NAME_KEY = '_applicationName';
    /**
     * @var string
     */
    public const PROJECT_DATA_GROUPS_APPLICATIONS_KEY = 'applications';
    /**
     * @var string
     */
    public const PROJECT_DATA_GROUPS_KEY = 'groups';
    /**
     * @var string
     */
    public const PROJECT_DATA_HOSTS_KEY = '_hosts';
    /**
     * @var string
     */
    public const PROJECT_DATA_INTERNAL_PROJECT_NAME_KEY = '_internal_project_name';
    /**
     * @var string
     */
    public const PROJECT_DATA_MOUNT_MODE_KEY = '_mountMode';
    /**
     * @var string
     */
    public const PROJECT_DATA_PORTS_KEY = '_ports';
    /**
     * @var string
     */
    public const PROJECT_DATA_PROJECT_NAME_KEY = '_project_name';
    /**
     * @var string
     */
    public const PROJECT_DATA_PROJECT_PATH_KEY = '_project_path';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_KEY = 'regions';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_SERVICES_DATABASES_KEY = 'databases';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_SERVICES_DATABASE_DATABASE_KEY = 'database';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_SERVICES_DATABASE_KEY = 'database';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_SERVICES_KEY = 'services';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_KEY = 'stores';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_SERVICES_BROKER_KEY = 'broker';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_SERVICES_BROKER_NAMESPACE_KEY = 'namespace';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_SERVICES_DATABASE_KEY = 'database';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_SERVICES_DATABASE_NAME_KEY = 'name';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_SERVICES_KEY = 'services';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_SERVICES_SEARCH_KEY = 'search';
    /**
     * @var string
     */
    public const PROJECT_DATA_REGIONS_STORES_SERVICES_SEARCH_NAMESPACE_KEY = 'namespace';
    /**
     * @var string
     */
    public const PROJECT_DATA_SERVICES_DEPLOYMENT_PATH_KEY = 'deployment_path';
    /**
     * @var string
     */
    public const PROJECT_DATA_SERVICES_ENDPOINTS_KEY = 'endpoints';
    /**
     * @var string
     */
    public const PROJECT_DATA_SERVICES_KEY = 'services';
    /**
     * @var string
     */
    public const PROJECT_DATA_SERVICES_PROJECT_NAME_KEY = 'project_name';
    /**
     * @var string
     */
    public const PROJECT_DATA_SERVICES_STORAGE_DATA_HOSTS_KEY = 'hosts';
    /**
     * @var string
     */
    public const PROJECT_DATA_SERVICES_STORAGE_DATA_KEY = 'storageData';
    /**
     * @var string
     */
    public const PROJECT_DATA_SERVICES_STORAGE_DATA_SERVICES_KEY = 'services';
    /**
     * @var string
     */
    public const PROJECT_DATA_SYNC_IGNORE_KEY = '_syncIgnore';
    /**
     * @var string
     */
    public const PROJECT_PATH_FILENAME = 'project_path';
    /**
     * @var string
     */
    public const SHARED_SERVICES_DEPLOYMENT_PATH_KEY = 'deployment_path';
    /**
     * @var string
     */
    public const SHARED_SERVICES_ENDPOINTS_KEY = 'endpoint';
    /**
     * @var string
     */
    public const SHARED_SERVICES_PROJECT_NAME_KEY = 'project_name';
    /**
     * @var string
     */
    public const SHARED_SERVICES_SERVICE_NAME_KEY = '_service_name';
    /**
     * @var string
     */
    public const SPRYKER_DOCKER_SDK_DEPLOYMENT_DIR = '/Users/sushko/.docker-sdk/deployment/split1';
    /**
     * @var string
     */
    public const SPRYKER_DOCKER_SDK_INTERNAL_DEPLOYMENT_DIR = '/data/deployment';
    /**
     * @var string
     */
    public const SPRYKER_INTERNAL_PROJECT_NAME = 'docker_sdk_spryker';
    /**
     * @var string
     */
    public const SPRYKER_PROJECT_NAME = 'split1';
    /**
     * @var string
     */
    public const SPRYKER_PROJECT_PATH = '/Users/sushko/Projects/test-one-docker/split1';
    /**
     * @var array
     */
    public const SPRYKER_SHARED_SERVICES_LIST = ['gateway', 'broker', 'dashboard', 'database', 'key_value_store', 'kibana', 'mail_catcher', 'redis-gui', 'scheduler', 'search', 'session'];
}
