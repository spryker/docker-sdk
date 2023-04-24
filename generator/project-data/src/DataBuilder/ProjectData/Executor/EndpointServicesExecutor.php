<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class EndpointServicesExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        foreach ($projectData['groups'] ?? [] as $groupName => $groupData) {
            foreach ($groupData['applications'] ?? [] as $applicationName => $applicationData) {
                foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {
                    $isEndpointDataHasStore = array_key_exists('store', $endpointData);
                    $isEndpointDataHasRegion = array_key_exists('region', $endpointData);

                    if ($isEndpointDataHasStore) { // todo: to builder
                        $services = array_replace_recursive(
                            $projectData['regions'][$groupData['region']]['stores'][$endpointData['store']]['services'],
                            $endpointData['services'] ?? []
                        );
                    }

                    if ($isEndpointDataHasRegion) { // todo: to builder
                        $services = array_replace_recursive(
                            $projectData['regions'][$groupData['region']]['services'],
                            $endpointData['services'] ?? []
                        );
                    }
                }
            }
        }


        return $projectData;
    }
}
