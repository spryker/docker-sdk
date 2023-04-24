<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\DataBuilder\DataBuilder\AbstractDataBuilder;
use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;
use ProjectData\ProjectDataConstants;

class CloudBrokerConnectionsExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $connections = [];

        $brokerServiceData = $projectData['services']['broker'] ?? [];

        foreach ($projectData['regions'] as $regionName => $regionData) {
            $regionServiceData = $brokerServiceData;
            if (isset($regionData['services']['broker'])) {
                $regionServiceData = array_replace($regionServiceData, $regionData['services']['broker']);
                $connections[$regionName] = [
                    'RABBITMQ_VIRTUAL_HOST' => $regionServiceData['namespace'],
                ];
            }
            foreach ($regionData['stores'] ?? [] as $storeName => $storeData) {
                if (!isset($storeData['services']['broker'])) {
                    continue;
                }
                $localServiceData = array_replace($brokerServiceData, $storeData['services']['broker']);
                $connections[$storeName] = [
                    'RABBITMQ_VIRTUAL_HOST' => $localServiceData['namespace'],
                ];
            }
        }

        $projectData[ProjectDataConstants::PROJECT_DATA_CLOUD_BROKER_CONNECTIONS_KEY] = json_encode($connections);

        return $projectData;
    }
}
