<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataReader;

use ProjectData\Constant\ProjectDataConstants;

class ProjectDataReader
{
    /**
     * @param array $projectData
     *
     * @return bool
     */
    public static function isDynamicStoreModeEnabled(array $projectData): bool
    {
        $envs = $projectData[ProjectDataConstants::PROJECT_DATA_ENVS_KEY] ?? [];

        return $envs[ProjectDataConstants::PROJECT_DATA_ENV_SPRYKER_DYNAMIC_STORE_MODE_KEY] ?? false;
    }
}
