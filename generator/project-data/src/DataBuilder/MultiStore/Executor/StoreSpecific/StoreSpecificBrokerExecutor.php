<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore\Executor\StoreSpecific;

use ProjectData\Constant\ProjectDataRegionsConstants;
use ProjectData\Constant\ProjectDataServicesConstants;
use ProjectData\Constant\ProjectDataStoreSpecificConstants;
use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class StoreSpecificBrokerExecutor implements DataExecutorInterface
{
    /**
     * @param array $projectData
     *
     * @return array
     */
    public function exec(array $projectData): array
    {
        $storeSpecific = $projectData[ProjectDataStoreSpecificConstants::STORE_SPECIFIC_KEY] ?? [];

        foreach ($projectData[ProjectDataRegionsConstants::REGIONS_KEY] as $regionName => $regionData) {
            $regionServices = $regionData[ProjectDataServicesConstants::SERVICES_KEY] ?? [];

            if (!isset($regionServices[ProjectDataServicesConstants::BROKER_KEY][ProjectDataServicesConstants::SERVICES_NAMESPACE_KEY])) {
                continue;
            }

            $keyValueStoreNamespace = $regionServices[ProjectDataServicesConstants::BROKER_KEY][ProjectDataServicesConstants::SERVICES_NAMESPACE_KEY];
            $storeSpecific[$regionName][ProjectDataStoreSpecificConstants::SPRYKER_BROKER_NAMESPACE] = $keyValueStoreNamespace;
        }

        $projectData[ProjectDataStoreSpecificConstants::STORE_SPECIFIC_KEY] = $storeSpecific;

        return $projectData;
    }
}
