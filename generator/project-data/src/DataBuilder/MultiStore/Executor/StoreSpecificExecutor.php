<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;
use ProjectData\ProjectDataConstants;

class StoreSpecificExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $storeSpecific = $projectData[ProjectDataConstants::PROJECT_DATA_STORE_SPECIFIC_KEY] ?? []; // todo: prepared into index.php

        foreach ($projectData[ProjectDataConstants::PROJECT_DATA_REGIONS_KEY] as $regionName => $regionData) {
            $regionServices = $regionData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY] ?? [];

            $storeSpecific = $this->addServiceNamespace(
                $regionName,
                $storeSpecific,
                $regionServices,
                ProjectDataConstants::PROJECT_DATA_KEY_VALUE_STORE_KEY,
                ProjectDataConstants::SPRYKER_KEY_VALUE_STORE_NAMESPACE
            );

            $storeSpecific = $this->addServiceNamespace(
                $regionName,
                $storeSpecific,
                $regionServices,
                ProjectDataConstants::PROJECT_DATA_BROKER_KEY,
                ProjectDataConstants::SPRYKER_BROKER_NAMESPACE
            );

            $storeSpecific = $this->addServiceNamespace(
                $regionName,
                $storeSpecific,
                $regionServices,
                ProjectDataConstants::PROJECT_DATA_SESSION_KEY,
                ProjectDataConstants::SPRYKER_SESSION_BE_NAMESPACE
            );
        }

        $projectData[ProjectDataConstants::PROJECT_DATA_STORE_SPECIFIC_KEY] = $storeSpecific;

        return $projectData;
    }

    protected function addServiceNamespace(
        string $regionName,
        array $storeSpecific,
        array $services,
        string $serviceKey,
        string $serviceNamespaceKey
    ): array {
        if (!isset($services[$serviceKey][ProjectDataConstants::PROJECT_DATA_NAMESPACE_KEY])) {
            return $storeSpecific;
        }

        $storeSpecific[$regionName][$serviceNamespaceKey] = $services[$serviceKey][ProjectDataConstants::PROJECT_DATA_NAMESPACE_KEY];

        return $storeSpecific;
    }
}
