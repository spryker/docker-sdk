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

class BrokerConnectionsExecutor implements DataExecutorInterface
{
    /**
     * @param array $projectData
     *
     * @return array
     */
    public function exec(array $projectData): array
    {
        $services = $projectData[ProjectDataServicesConstants::SERVICES_KEY] ?? [];
        $brokerServiceData = $services[ProjectDataServicesConstants::BROKER_KEY] ?? [];

        if (empty($brokerServiceData)) {
            $projectData[ProjectDataConstants::PROJECT_DATA_BROKER_CONNECTIONS_KEY] = json_encode([]);

            return $projectData;
        }

        $projectData[ProjectDataConstants::PROJECT_DATA_BROKER_CONNECTIONS_KEY] = $this->buildConnections(
            $projectData,
            $brokerServiceData
        );

        return $projectData;
    }

    /**
     * @param array $projectData
     * @param array $brokerServiceData
     *
     * @return string
     */
    protected function buildConnections(array $projectData, array $brokerServiceData): string
    {
        $connections = [];

        $regionsData = $projectData[ProjectDataRegionsConstants::REGIONS_KEY];

        foreach ($regionsData as $regionName => $regionData) {
            $storesData = $regionData[ProjectDataRegionsConstants::STORES_KEY] ?? [];

            if (isset($regionData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY])) {
                $connections = $this->createConnection(
                    $connections,
                    $regionName,
                    $regionData,
                    $brokerServiceData
                );
            }

            foreach ($storesData as $storeName => $storeData) {
                if (!isset($storeData[$storeName][ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY])) {
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

    /**
     * @param array $connections
     * @param string $name
     * @param array $serviceData
     * @param array $brokerServiceData
     * @param array $storeNames
     *
     * @return array
     */
    protected function createConnection(
        array $connections,
        string $name,
        array $serviceData,
        array $brokerServiceData,
        array $storeNames = []
    ): array {
        $serviceData = array_replace(
            $brokerServiceData,
            $serviceData[ProjectDataServicesConstants::SERVICES_KEY][ProjectDataServicesConstants::BROKER_KEY]
        );

        $connections[$name] = [
            'RABBITMQ_CONNECTION_NAME' => $name . '-connection',
            'RABBITMQ_HOST' => ProjectDataServicesConstants::BROKER_KEY,
            'RABBITMQ_PORT' => $serviceData[ProjectDataServicesConstants::SERVICE_PORT_KEY] ?? 5672,
            'RABBITMQ_USERNAME' => $serviceData[ProjectDataServicesConstants::SERVICE_API_KEY][ProjectDataServicesConstants::SERVICE_USERNAME_KEY] ?? '',
            'RABBITMQ_PASSWORD' => $serviceData[ProjectDataServicesConstants::SERVICE_API_KEY][ProjectDataServicesConstants::SERVICE_PASSWORD_KEY] ?? '',
            'RABBITMQ_VIRTUAL_HOST' => $serviceData[ProjectDataServicesConstants::SERVICES_NAMESPACE_KEY] ?? '',
            'RABBITMQ_STORE_NAMES' => $storeNames,
        ];

        return $connections;
    }
}
