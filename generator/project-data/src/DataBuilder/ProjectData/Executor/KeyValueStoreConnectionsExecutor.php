<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;
use ProjectData\ProjectDataConstants;

class KeyValueStoreConnectionsExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $connections = [];

        $keyValueStoreData = $projectData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_KEY];

        foreach ($projectData[ProjectDataConstants::PROJECT_DATA_REGIONS_KEY] as $regionName => $regionData) {
            $regionKeyValueStoreData = $keyValueStoreData;

            if (isset($regionData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_KEY])) {
                $connections[$regionName] = $regionKeyValueStoreData = array_replace(
                    $regionKeyValueStoreData,
                    $regionData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_KEY]
                );
            }

            foreach ($regionData[ProjectDataConstants::PROJECT_DATA_STORE_KEY] ?? [] as $storeName => $storeData) {
                if (!isset($storeData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_KEY])) {
                    continue;
                }

                $connections[$storeName] = array_replace(
                    $regionKeyValueStoreData,
                    $storeData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_KEY]
                );
            }
        }

        $connections = json_encode($connections);
        $projectData[ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_CONNECTIONS_KEY] = $connections;

        return $projectData;
    }
}
