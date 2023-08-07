<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\DataBuilder;

interface DataBuilderStrategyInterface
{
    /**
     * @param array $projectData
     *
     * @return bool
     */
    public function isApplicable(array $projectData): bool;

    /**
     * @param array $projectData
     *
     * @return array
     */
    public function build(array $projectData): array;
}
