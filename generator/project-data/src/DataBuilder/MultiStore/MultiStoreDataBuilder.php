<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore;

use ProjectData\DataBuilder\DataBuilder\AbstractDataBuilder;
use ProjectData\DataReader\ProjectDataReader;

class MultiStoreDataBuilder extends AbstractDataBuilder
{
    public function build(array $projectData): array
    {
        if (!ProjectDataReader::isDynamicStoreModeEnabled($projectData)) {
            return $projectData;
        }

        return parent::build($projectData);
    }
}
