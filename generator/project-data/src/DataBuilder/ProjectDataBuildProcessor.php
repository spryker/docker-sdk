<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder;

class ProjectDataBuildProcessor
{
    /**
     * @var \ProjectData\DataBuilder\DataBuilder\DataBuilderStrategyInterface[]
     */
    protected array $dataBuilderList;

    /**
     * @param \ProjectData\DataBuilder\DataBuilder\DataBuilderStrategyInterface[] $dataBuilderList
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
            if (!$dataBuilder->isApplicable($projectData)) {
                continue;
            }
            $projectData = $dataBuilder->build($projectData);
        }

        return $projectData;
    }
}
