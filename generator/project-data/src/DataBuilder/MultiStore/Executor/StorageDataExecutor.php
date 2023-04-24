<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;
use ProjectData\DataReader\ProjectDataReader;

class StorageDataExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $storageData = $projectData['storageData'];
        $hosts = $storageData['hosts'];
        $hosts = array_merge(
            $hosts,
            $this->buildRegionsStorageHosts($projectData),
        );

        $projectData['storageData']['hosts'] = $hosts;

        return $projectData;
    }

    private function buildRegionsStorageHosts(array $projectData): array
    {
        $regionsStorageHosts = [];
        $regions = ProjectDataReader::getRegions($projectData);
        $storageServices = $projectData['storageData']['services'] ?? [];
        $defaultPort = 6379;

        foreach ($regions as $regionData) {
            foreach ($regionData['services'] ?? [] as $serviceName => $serviceNamespace) {
                if (in_array($serviceName, $storageServices, true)) {
                    $regionsStorageHosts[] = sprintf('%s:%s:%s:%s', $serviceName, $serviceName, $defaultPort,
                        $serviceNamespace['namespace']);
                }
            }
        }

        return $regionsStorageHosts;
    }
}
