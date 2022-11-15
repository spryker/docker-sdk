<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSdk\DataBuilder\SharedServices\Plugins;

use DockerSdk\DataBuilder\AbstractPlugin;
use DockerSdk\DockerSdkConstants;

class RedisGuiPlugin extends AbstractPlugin implements SharedServicesPluginInterface
{
    const SERVICE_NAME = 'redis-gui';

    public function buildProjectSharedServiceData(
        string $serviceName,
        array $projectServiceData,
        array $sharedServiceData
    ): array {
        if ($serviceName !== self::SERVICE_NAME) {
            return $sharedServiceData;
        }

        $projectStorageData = $projectServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY];

        $projectStorageData = $this->buildHosts($projectStorageData);
        $projectStorageData = $this->buildServices($projectStorageData);

        $sharedServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY] = $projectStorageData;

        return $sharedServiceData;
    }

    public function buildSharedServicesData(string $serviceName, array $projectServiceData, array $sharedServiceData): array
    {
        if ($serviceName !== self::SERVICE_NAME) {
            return $sharedServiceData;
        }

        $sharedServiceStorageData = $sharedServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY] ?? [];
        $projectStorageData = $projectServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY] ?? [];

        $storageData = array_merge_recursive(
            $projectStorageData,
            $sharedServiceStorageData
        );

        $sharedServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY] = $storageData;

        $hosts = array_unique($sharedServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY][DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_HOSTS_KEY]);
        $services = array_unique($sharedServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY][DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_SERVICES_KEY]);

        $sharedServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY][DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_HOSTS_KEY] = $hosts;
        $sharedServiceData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_KEY][DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_SERVICES_KEY] = $services;

        return $sharedServiceData;
    }

    private function buildServices(array $projectStorageData): array
    {
        $result = [];
        $sharedServices = array_flip($this->config->getSharedServiceList());

        $services = $projectStorageData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_SERVICES_KEY] ?? [];

        foreach ($services as $serviceName) {
            if (array_key_exists($serviceName, $sharedServices)) {
                $result[] = $this->config->getInternalProjectName() . '_' . $serviceName;

                continue;
            }

            $result[] = $this->config->getSprykerProjectName() . '_' . $serviceName;
        }

        $projectStorageData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_SERVICES_KEY] = $result;

        return $projectStorageData;
    }

    private function buildHosts(array $projectStorageData): array
    {
        $result = [];
        $sharedServices = array_flip($this->config->getSharedServiceList());

        $hosts = $projectStorageData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_HOSTS_KEY] ?? [];

        foreach ($hosts as $host) {
            $host = explode(':', $host);
//            todo: possible bug with indexes
            $serviceName = $host[0];
            $projectName = $this->config->getSprykerProjectName();

            if (array_key_exists($serviceName, $sharedServices)) {
                $projectName = $this->config->getInternalProjectName();
            }

            $host[0] = $projectName . '_' . $serviceName;
            $host[1] = $projectName . '_' . $serviceName;

            $result[] = implode(':', $host);
        }

        $projectStorageData[DockerSdkConstants::PROJECT_DATA_SERVICES_STORAGE_DATA_HOSTS_KEY] = $result;

        return $projectStorageData;
    }
}
