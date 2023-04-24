<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;
use ProjectData\DataReader\ProjectDataReader;
use ProjectData\ProjectDataConstants;

class BrokerHostsExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $hosts = [];
        $regions = ProjectDataReader::getRegions($projectData);

        foreach ($regions as $regionName => $regionData) {
            $services = $regionData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY] ?? [];

            $host = $services['broker']['namespace'] ?? null;

            if ($host !== null) {
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
