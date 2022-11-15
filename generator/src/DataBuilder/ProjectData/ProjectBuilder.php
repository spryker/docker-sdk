<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSdk\DataBuilder\ProjectData;

use DockerSdk\DataBuilder\AbstractBuilder;
use DockerSdk\DockerSdkConstants;
use DockerSdk\Helpers\ContainerNameBuilder;

class ProjectBuilder extends AbstractBuilder
{
    public function build(array $projectData): array
    {
        $projectDataFromFile = $this->reader->read(
            $this->config->getProjectDataFilePath()
        );

        $projectData = $this->buildGroups($projectData);
        $projectData = $this->addProjectName($projectData);
        $projectData = $this->addProjectPath($projectData);
        $projectData = $this->addInternalNamespace($projectData);
        $projectData = $this->addDeployPath($projectData);
        $projectData = $this->addDebugMode($projectData);
        $projectData = $this->addSharedServicesData($projectData);
        $projectData = $this->buildServices($projectData);
        $projectData = $this->buildSearch($projectData);
        $projectData = $this->buildBrokerNamespaces($projectData);
        $projectData = $this->buildDb($projectData);

        $projectDataFromFile[$this->config->getSprykerProjectName()] = $projectData;

        $this->writer->write(
            $this->config->getProjectDataFilePath(),
            $projectDataFromFile
        );

        return $projectData;
    }


    private function buildGroups(array $projectData): array
    {
        $projectGroups = $projectData[DockerSdkConstants::PROJECT_DATA_GROUPS_KEY];

        foreach ($projectGroups as $groupName => $groupData) {
            $groupsApplications = $groupData[DockerSdkConstants::PROJECT_DATA_GROUPS_APPLICATIONS_KEY];

            foreach ($groupsApplications as $applicationName => $applicationData) {
                $applicationData[DockerSdkConstants::PROJECT_DATA_GROUPS_APPLICATIONS_APPLICATION_NAME_KEY] = $this->config->getSprykerProjectName();
                $applicationData[DockerSdkConstants::PROJECT_DATA_GROUPS_APPLICATIONS_APPLICATION_DEPLOYMENT_PATH_KEY] = $this->config->getProjectDeploymentDir();

                $projectGroups[$groupName][$applicationName] = $applicationData;
            }
        }

        $projectData[DockerSdkConstants::PROJECT_DATA_GROUPS_KEY] = $projectGroups;

        return $projectData;
    }

    private function addInternalNamespace(array $projectData): array
    {
        $projectData[DockerSdkConstants::PROJECT_DATA_INTERNAL_PROJECT_NAME_KEY] = $this->config->getInternalProjectName();

        return $projectData;
    }

    private function addProjectName(array $projectData): array
    {
        $projectData[DockerSdkConstants::PROJECT_DATA_PROJECT_NAME_KEY] = $this->config->getSprykerProjectName();

        return $projectData;
    }

    private function addDeployPath(array $projectData): array
    {
        $projectData[DockerSdkConstants::PROJECT_DATA_DEPLOYMENT_PATH_KEY] = $this->config->getProjectDeploymentDir();

        return $projectData;
    }

    private function addSharedServicesData(array $projectData): array
    {
        $projectServices = $projectData[DockerSdkConstants::PROJECT_DATA_SERVICES_KEY];
        $sharedServicesData = $this->reader->read($this->config->getDockerComposeSharedServiceDataFilePath());

        foreach ($sharedServicesData as $servicesName => $servicesData) {
            $projectServices[$servicesName] = $servicesData;
        }

        $projectData[DockerSdkConstants::PROJECT_DATA_SERVICES_KEY] = $projectServices;

        return $projectData;
    }

    private function addProjectPath(array $projectData): array
    {
        $projectData[DockerSdkConstants::PROJECT_DATA_PROJECT_PATH_KEY] = $this->config->getSprykerProjectPath();

        return $projectData;
    }

    private function addDebugMode(array $projectData): array
    {
        $isDebugModeEnabled = $projectData[DockerSdkConstants::PROJECT_DATA_DOCKER_KEY] ?? false;
        $isDebugModeEnabled = $isDebugModeEnabled[DockerSdkConstants::PROJECT_DATA_DOCKER_DEBUG_KEY] ?? false;
        $isDebugModeEnabled = $isDebugModeEnabled[DockerSdkConstants::PROJECT_DATA_DOCKER_DEBUG_XDEBUG_KEY] ?? false;
        $isDebugModeEnabled = $isDebugModeEnabled[DockerSdkConstants::PROJECT_DATA_DOCKER_DEBUG_XDEBUG_ENABLED_KEY] ?? false;

        $projectData[DockerSdkConstants::PROJECT_DATA_DEBUG_MODE_ENABLED_KEY] = $isDebugModeEnabled;

        return $projectData;
    }

    private function buildServices(array $projectData): array
    {
        $projectServices = $projectData[DockerSdkConstants::PROJECT_DATA_SERVICES_KEY];
        $sharedServicesData = $this->reader->read($this->config->getDockerComposeSharedServiceDataFilePath());

        foreach ($projectServices as $serviceName => $serviceData) {
            if (array_key_exists($serviceName, $sharedServicesData)) {
                continue;
            }

            $serviceData[DockerSdkConstants::PROJECT_DATA_SERVICES_DEPLOYMENT_PATH_KEY] = $this->config->getProjectDeploymentDir();
            $serviceData[DockerSdkConstants::PROJECT_DATA_SERVICES_PROJECT_NAME_KEY] = $this->config->getSprykerProjectName();

            $projectServices[$serviceName] = $serviceData;
        }

        $projectData[DockerSdkConstants::PROJECT_DATA_SERVICES_KEY] = $projectServices;

        return $projectData;
    }

    private function buildBrokerNamespaces(array $projectData): array
    {
        $regions = $projectData[DockerSdkConstants::PROJECT_DATA_REGIONS_KEY];

        foreach ($regions as $regionName => $regionData) {
            $stores = $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_KEY];

            foreach ($stores as $storeName => $storeData) {
                $services = $storeData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_KEY];
                $broker = $services[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_BROKER_KEY];
                $namespace = $broker[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_BROKER_NAMESPACE_KEY];
                $namespace = sprintf(
                    '%s-%s',
                    $projectData[DockerSdkConstants::PROJECT_DATA_PROJECT_NAME_KEY],
                    $namespace
                );
                $services[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_BROKER_KEY][DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_BROKER_NAMESPACE_KEY] = $namespace;
                $storeData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_KEY] = $services;
                $stores[$storeName] = $storeData;
            }

            $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_KEY] = $stores;
            $regions[$regionName] = $regionData;
        }
        $projectData[DockerSdkConstants::PROJECT_DATA_REGIONS_KEY] = $regions;

        return $projectData;
    }

    private function buildSearch(array $projectData): array
    {
        $regions = $projectData[DockerSdkConstants::PROJECT_DATA_REGIONS_KEY];

        foreach ($regions as $regionName => $regionData) {
            $stores = $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_KEY];

            foreach ($stores as $storeName => $storeData) {
                $services = $storeData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_KEY];
                $search = $services[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_SEARCH_KEY];
                $namespace = $search[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_SEARCH_NAMESPACE_KEY];
                $namespace = sprintf(
                    '%s_%s',
                    $projectData[DockerSdkConstants::PROJECT_DATA_PROJECT_NAME_KEY],
                    $namespace
                );
                $services[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_SEARCH_KEY][DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_SEARCH_NAMESPACE_KEY] = $namespace;
                $storeData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_KEY] = $services;
                $stores[$storeName] = $storeData;
            }

            $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_KEY] = $stores;
            $regions[$regionName] = $regionData;
        }
        $projectData[DockerSdkConstants::PROJECT_DATA_REGIONS_KEY] = $regions;

        return $projectData;
    }

    private function buildDb(array $projectData): array
    {
        $regions = $projectData[DockerSdkConstants::PROJECT_DATA_REGIONS_KEY];

        foreach ($regions as $regionName => $regionData) {
            $services = $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_KEY];

            if (array_key_exists(DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_DATABASE_KEY, $services)) {
                $database = $services[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_DATABASE_KEY];
                $databaseName = $database[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_DATABASE_DATABASE_KEY];
                $databaseName = sprintf(
                    '%s-%s',
                    $projectData[DockerSdkConstants::PROJECT_DATA_PROJECT_NAME_KEY],
                    $databaseName
                );

                $database[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_DATABASE_DATABASE_KEY] = $databaseName;
                $services[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_DATABASE_KEY] = $database;
                $regions[$regionName][DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_KEY] = $services;

                continue;
            }

            $databases = $services[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_DATABASES_KEY];
            $databasesResult = [];

            foreach ($databases as $databaseName => $databaseData) {
                $databaseNameWithProjectPrefix = sprintf(
                    '%s-%s',
                    $projectData[DockerSdkConstants::PROJECT_DATA_PROJECT_NAME_KEY],
                    $databaseName
                );

                $stores = $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_KEY];

                foreach ($stores as $storeName => $storeData) {
                    $services = $storeData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_KEY];
                    $database = $services[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_DATABASE_KEY];
                    $database[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_DATABASE_NAME_KEY] = $databaseNameWithProjectPrefix;
                    $services[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_DATABASE_KEY] = $database;
                    $storeData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_SERVICES_KEY] = $services;
                    $stores[$storeName] = $storeData;
                }

                $databasesResult[$databaseName] = $databaseData;
                $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_STORES_KEY] = $stores;
            }

            $services[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_DATABASES_KEY] = $databasesResult;
            $regionData[DockerSdkConstants::PROJECT_DATA_REGIONS_SERVICES_KEY] = $services;
            $regions[$regionName] = $regionData;
        }

        $projectData[DockerSdkConstants::PROJECT_DATA_REGIONS_KEY] = $regions;

        return $projectData;
    }
}
