<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\MergeResolver;

interface MergeResolverInterface
{
    /**
     * @param array $projectData
     * @param array $importData
     *
     * @return array
     */
    public function resolve(array $projectData, array $importData): array;
}
