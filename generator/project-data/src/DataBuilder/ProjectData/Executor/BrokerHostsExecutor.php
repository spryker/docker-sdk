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

class BrokerHostsExecutor implements DataExecutorInterface
{
    /**
     * @param array $projectData
     *
     * @return array
     */
    public function exec(array $projectData): array
    {
        $hosts = [];

        $regions = $projectData[ProjectDataRegionsConstants::REGIONS_KEY] ?? [];

        foreach ($regions as $regionData) {
            $stores = $regionData[ProjectDataRegionsConstants::STORES_KEY] ?? [];

            foreach ($stores as $storeData) {
                $host = $storeData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY][ProjectDataServicesConstants::SERVICES_NAMESPACE_KEY] ?? null;

                if ($host === null) {
                    continue;
                }

                $hosts[] = $host;
            }
        }

        $projectData[ProjectDataConstants::PROJECT_DATA_BROKER_HOSTS_KEY] = implode(
            ' ',
            array_values($hosts)
        );

        return $projectData;
    }
}
