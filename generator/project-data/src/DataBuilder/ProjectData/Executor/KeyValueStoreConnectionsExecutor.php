<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\Constant\ProjectDataConstants;
use ProjectData\Constant\ProjectDataRegionsConstants;
use ProjectData\Constant\ProjectDataServicesConstants;
use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class KeyValueStoreConnectionsExecutor implements DataExecutorInterface
{
    /**
     * @param array $projectData
     *
     * @return array
     */
    public function exec(array $projectData): array
    {
        $connections = [];

        if (!isset($projectData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::KEY_VALUE_STORE_KEY])) {
            return $projectData;
        }

        $keyValueStoreData = $projectData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::KEY_VALUE_STORE_KEY];

        foreach ($projectData[ProjectDataRegionsConstants::REGIONS_KEY] as $regionName => $regionData) {
            $regionKeyValueStoreData = $keyValueStoreData;

            if (isset($regionData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::KEY_VALUE_STORE_KEY])) {
                $connections[$regionName] = $regionKeyValueStoreData = array_replace(
                    $regionKeyValueStoreData,
                    $regionData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::KEY_VALUE_STORE_KEY]
                );
            }

            foreach ($regionData[ProjectDataRegionsConstants::STORES_KEY] ?? [] as $storeName => $storeData) {
                if (!isset($storeData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::KEY_VALUE_STORE_KEY])) {
                    continue;
                }

                $connections[$storeName] = array_replace(
                    $regionKeyValueStoreData,
                    $storeData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::KEY_VALUE_STORE_KEY]
                );
            }
        }

        $connections = json_encode($connections);
        $projectData[ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_CONNECTIONS_KEY] = $connections;

        return $projectData;
    }
}
