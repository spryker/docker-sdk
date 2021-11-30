<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\MergeResolver;

use Codeception\Test\Unit;
use DeployFileGenerator\MergeResolver\DeployFileMergeResolver;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;

class YamlDeployFileMergeResolverTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testResolve(): void
    {
        // Arrange
        $yamlDeployFileMergeResolver = new DeployFileMergeResolver(
            $this->createMergeResolverCollection(),
        );

        $projectData = [
            'env' => 'some data',
            'services' => [
                'search' => [
                    'engine' => 'search',
                ],
            ],
        ];

        $importData = [
            'services' => [
                'redis' => [
                    'engine' => 'redis',
                ],
                'db' => [
                    'engine' => 'mysql',
                ],
            ],
        ];

        // Act
        $result = $yamlDeployFileMergeResolver->resolve($projectData, $importData);

        // Assert
        $this->tester->assertEquals([
            'env' => 'data from merge resolver',
            'services' => null,
        ], $result);
    }

    /**
     * @return array
     */
    protected function createMergeResolverCollection(): array
    {
        return [
            $this->makeEmpty(MergeResolverInterface::class, [
                'resolve' => function (array $projectData, array $importData) {
                    $result = array_replace_recursive($importData, $projectData);

                    if (!array_key_exists('services', $result)) {
                        return $result;
                    }

                    $result['services'] = null;

                    return $result;
                },
            ]),
            $this->makeEmpty(MergeResolverInterface::class, [
                'resolve' => function (array $projectData, array $importData) {
                    $result = array_replace_recursive($importData, $projectData);

                    if (!array_key_exists('env', $result)) {
                        return $result;
                    }

                    $result['env'] = 'data from merge resolver';

                    return $result;
                },
            ]),
        ];
    }
}
