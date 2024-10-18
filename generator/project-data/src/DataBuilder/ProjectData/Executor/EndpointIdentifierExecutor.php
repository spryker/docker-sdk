<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\Constant\ProjectDataGroupsConstants;
use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class EndpointIdentifierExecutor implements DataExecutorInterface
{
    /**
     * @param array $projectData
     *
     * @return array
     */
    public function exec(array $projectData): array
    {
        $groups = $projectData[ProjectDataGroupsConstants::GROUPS_KEY] ?? [];

        foreach ($groups as $groupName => $groupData) {
            $groupApplications = $groupData[ProjectDataGroupsConstants::APPLICATIONS_KEY] ?? [];

            foreach ($groupApplications as $applicationName => $applicationData) {
                $applicationEndpoints = $applicationData[ProjectDataGroupsConstants::ENDPOINTS_KEY] ?? [];

                foreach ($applicationEndpoints as $endpoint => $endpointData) {
                    if ($endpointData === null) {
                        $endpointData = [];
                    }

                    $store = $endpointData[ProjectDataGroupsConstants::STORE_KEY] ?? null;
                    $region = $endpointData[ProjectDataGroupsConstants::REGION_KEY] ?? null;
                    $projectData[ProjectDataGroupsConstants::GROUPS_KEY][$groupName][ProjectDataGroupsConstants::APPLICATIONS_KEY][$applicationName][ProjectDataGroupsConstants::ENDPOINTS_KEY][$endpoint][ProjectDataGroupsConstants::IDENTIFIER_KEY] = $store ?: $region;
                }
            }
        }

        return $projectData;
    }
}
