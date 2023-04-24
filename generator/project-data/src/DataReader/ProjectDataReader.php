<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataReader;

use ProjectData\ProjectDataConstants;

class ProjectDataReader
{
    public static function getServices(array $projectData): array
    {
        return $projectData[ProjectDataConstants::PROJECT_DATA_SERVICES_KEY] ?? [];
    }

    public static function getRegions(array $projectData): array
    {
        return $projectData[ProjectDataConstants::PROJECT_DATA_REGIONS_KEY] ?? [];
    }

    public static function getGroups(array $projectData): array
    {
        return $projectData[ProjectDataConstants::PROJECT_DATA_GROUPS_KEY] ?? [];
    }

    public static function isDynamicStoreModeEnabled(array $projectData): bool
    {
        $envs = $projectData[ProjectDataConstants::PROJECT_DATA_ENVS_KEY] ?? [];

        return $envs[ProjectDataConstants::PROJECT_DATA_ENV_SPRYKER_DYNAMIC_STORE_MODE_KEY] ?? false;
    }
}
