<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class EndpointIdentifierExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $groups = $projectData['groups'] ?? [];

        foreach ($groups as $groupName => $groupData) {
            $groupApplications = $groupData['applications'] ?? [];

            foreach ($groupApplications as $applicationName => $applicationData) {
                $applicationEndpoints = $applicationData['endpoints'] ?? [];

                foreach ($applicationEndpoints as $endpoint => $endpointData) {
                    if ($endpointData === null) {
                        $endpointData = [];
                    }

                    $store = $endpointData['store'] ?? null;
                    $region = $endpointData['region'] ?? null;
                    $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['identifier'] = $store ?: $region;
                }
            }
        }

        return $projectData;
    }
}
