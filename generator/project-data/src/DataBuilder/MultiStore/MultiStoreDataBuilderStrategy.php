<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore;

use ProjectData\DataBuilder\DataBuilder\AbstractDataBuilderStrategy;
use ProjectData\DataReader\ProjectDataReader;

class MultiStoreDataBuilderStrategy extends AbstractDataBuilderStrategy
{
    /**
     * @param array $projectData
     *
     * @return bool
     */
    public function isApplicable(array $projectData): bool
    {
        return ProjectDataReader::isDynamicStoreModeEnabled($projectData);
    }

    /**
     * @param array $projectData
     *
     * @return array
     */
    public function build(array $projectData): array
    {
        return parent::build($projectData);
    }
}
