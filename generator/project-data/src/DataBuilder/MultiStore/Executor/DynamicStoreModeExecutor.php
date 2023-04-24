<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;
use ProjectData\DataReader\ProjectDataReader;
use ProjectData\ProjectDataConstants;

class DynamicStoreModeExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $projectData[ProjectDataConstants::PROJECT_DATA_DYNAMIC_STORE_MODE_KEY] = ProjectDataReader::isDynamicStoreModeEnabled($projectData);

        return $projectData;
    }
}
