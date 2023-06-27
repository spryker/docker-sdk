<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\DataBuilder;

abstract class AbstractDataBuilderStrategy implements DataBuilderStrategyInterface
{
    /**
     * @var \ProjectData\DataBuilder\DataExecutor\DataExecutorInterface[]
     */
    protected array $executors;

    /**
     * @param \ProjectData\DataBuilder\DataExecutor\DataExecutorInterface[] $executors
     */
    public function __construct(array $executors = [])
    {
        $this->executors = $executors;
    }

    /**
     * @param array $projectData
     *
     * @return array
     */
    public function build(array $projectData): array
    {
        foreach ($this->executors as $projectDataExecutor) {
            $projectData = $projectDataExecutor->exec($projectData);
        }

        return $projectData;
    }
}
