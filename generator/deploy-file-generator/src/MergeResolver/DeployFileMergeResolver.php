<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\MergeResolver;

class DeployFileMergeResolver implements MergeResolverInterface
{
    /**
     * @var array<\DeployFileGenerator\MergeResolver\MergeResolverInterface>
     */
    protected $resolvers;

    /**
     * @param array<\DeployFileGenerator\MergeResolver\MergeResolverInterface> $resolvers
     */
    public function __construct(array $resolvers)
    {
        $this->resolvers = $resolvers;
    }

    /**
     * @param array $projectData
     * @param array $importData
     *
     * @return array
     */
    public function resolve(array $projectData, array $importData): array
    {
        foreach ($this->resolvers as $resolver) {
            $projectData = $resolver->resolve($projectData, $importData);
        }

        return $projectData;
    }
}
