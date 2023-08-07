<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore\Executor;

use ProjectData\Constant\ProjectDataRegionsConstants;
use ProjectData\Constant\ProjectDataServicesConstants;
use ProjectData\Constant\ProjectDataStorageDataConstants;
use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class StorageDataExecutor implements DataExecutorInterface
{
    protected const DEFAULT_PORT = 6379;

    /**
     * @param array $projectData
     *
     * @return array
     */
    public function exec(array $projectData): array
    {
        $storageData = $projectData[ProjectDataStorageDataConstants::STORAGE_DATA_KEY] ?? [];
        $hosts = $storageData[ProjectDataStorageDataConstants::STORAGE_DATA_HOSTS_KEY] ?? [];
        $hosts = array_merge(
            $hosts,
            $this->buildRegionsStorageHosts($projectData),
        );

        $storageData[ProjectDataStorageDataConstants::STORAGE_DATA_HOSTS_KEY] = $hosts;
        $projectData[ProjectDataStorageDataConstants::STORAGE_DATA_KEY] = $storageData;

        return $projectData;
    }

    /**
     * @param array $projectData
     *
     * @return array
     */
    protected function buildRegionsStorageHosts(array $projectData): array
    {
        $regionsStorageHosts = [];

        $regions = $projectData[ProjectDataRegionsConstants::REGIONS_KEY] ?? [];
        $storageData = $projectData[ProjectDataStorageDataConstants::STORAGE_DATA_KEY] ?? [];
        $storageServices = $storageData[ProjectDataStorageDataConstants::STORAGE_DATA_SERVICE_KEY] ?? [];

        foreach ($regions as $regionData) {
            $regionServices = $regionData[ProjectDataServicesConstants::SERVICES_KEY] ?? [];

            foreach ($regionServices as $serviceName => $serviceNamespace) {
                if (in_array($serviceName, $storageServices, true)) {
                    $regionsStorageHosts[] = sprintf(
                        '%s:%s:%s:%s',
                        $serviceName,
                        $serviceName,
                        static::DEFAULT_PORT,
                        $serviceNamespace[ProjectDataServicesConstants::SERVICES_NAMESPACE_KEY]
                    );
                }
            }
        }

        return $regionsStorageHosts;
    }
}
