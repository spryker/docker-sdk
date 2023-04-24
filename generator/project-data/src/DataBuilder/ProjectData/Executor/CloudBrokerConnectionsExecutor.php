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

class CloudBrokerConnectionsExecutor implements DataExecutorInterface
{
    /**
     * @param array $projectData
     *
     * @return array
     */
    public function exec(array $projectData): array
    {
        $connections = [];

        $brokerServiceData = $projectData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY] ?? [];

        foreach ($projectData[ProjectDataRegionsConstants::REGIONS_KEY] as $regionName => $regionData) {
            $regionServiceData = $brokerServiceData;

            if (isset($regionData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY])) {
                $regionServiceData = array_replace($regionServiceData, $regionData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY]);
                $connections[$regionName] = [
                    'RABBITMQ_VIRTUAL_HOST' => $regionServiceData[ProjectDataServicesConstants::SERVICES_NAMESPACE_KEY],
                ];
            }
            foreach ($regionData[ProjectDataRegionsConstants::STORES_KEY] ?? [] as $storeName => $storeData) {
                if (!isset($storeData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY])) {
                    continue;
                }

                $localServiceData = array_replace($brokerServiceData, $storeData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY]);
                $connections[$storeName] = [
                    'RABBITMQ_VIRTUAL_HOST' => $localServiceData[ProjectDataServicesConstants::SERVICES_NAMESPACE_KEY],
                ];
            }
        }

        $projectData[ProjectDataConstants::PROJECT_DATA_CLOUD_BROKER_CONNECTIONS_KEY] = json_encode($connections);

        return $projectData;
    }
}
