<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;
use ProjectData\ProjectDataConstants;

class BrokerConnectionsExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $brokerServiceData = $projectData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_BROKER_KEY] ?? [];

        if (empty($brokerServiceData)) {
            $projectData[ProjectDataConstants::PROJECT_DATA_BROKER_CONNECTIONS_KEY] = [];

            return $projectData;
        }

        $projectData[ProjectDataConstants::PROJECT_DATA_BROKER_CONNECTIONS_KEY] = $this->buildConnections(
            $projectData,
            $brokerServiceData
        );

        return $projectData;
    }

    private function buildConnections(array $projectData, array $brokerServiceData): string
    {
        $connections = [];

        $regionsData = $projectData[ProjectDataConstants::PROJECT_DATA_REGIONS_KEY];

        foreach ($regionsData as $regionName => $regionData) {
            $storesData = $regionData[ProjectDataConstants::PROJECT_DATA_STORE_KEY] ?? [];

            if (isset($regionData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_BROKER_KEY])) {
                $connections = $this->createConnection(
                    $connections,
                    $regionName,
                    $regionData,
                    $brokerServiceData
                );
            }


            foreach ($storesData as $storeName => $storeData) {
                if (!isset($storeData[$storeName][ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_BROKER_KEY])) {
                    $connections = $this->createConnection(
                        $connections,
                        $storeName,
                        $storeData,
                        $brokerServiceData,
                        [$storeName]
                    );
                }
            }
        }

        return json_encode($connections);
    }

    protected function createConnection(
        array $connections,
        string $name,
        array $serviceData,
        array $brokerServiceData,
        array $storeNames = []
    ): array {
        $serviceData = array_replace(
            $brokerServiceData,
            $serviceData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY][ProjectDataConstants::PROJECT_DATA_BROKER_KEY]
        );

        $connections[$name] = [
            'RABBITMQ_CONNECTION_NAME' => $name . '-connection',
            'RABBITMQ_HOST' => 'broker',
            'RABBITMQ_PORT' => $serviceData['port'] ?? 5672,
            'RABBITMQ_USERNAME' => $serviceData['api']['username'] ?? '',
            'RABBITMQ_PASSWORD' => $serviceData['api']['password'] ?? '',
            'RABBITMQ_VIRTUAL_HOST' => $serviceData['namespace'] ?? '',
            'RABBITMQ_STORE_NAMES' => $storeNames,
        ];

        return $connections;
    }
}
