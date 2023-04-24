<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder;

use ProjectData\DataBuilder\DataBuilder\DataBuilderInterface;

class ProjectDataBuildProcessor
{
    /**
     * @var DataBuilderInterface[]
     */
    protected array $dataBuilderList;

    /**
     * @param DataBuilderInterface[] $dataBuilderList
     */
    public function __construct(array $dataBuilderList)
    {
        $this->dataBuilderList = $dataBuilderList;
    }

    /**
     * @param array $projectData
     *
     * @return array
     */
    public function run(array $projectData): array
    {
        foreach ($this->dataBuilderList as $dataBuilder) {
            $projectData = $dataBuilder->build($projectData);
        }

        return $projectData;
    }
}
