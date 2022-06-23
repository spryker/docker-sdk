<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\MergeResolver\Resolvers;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\MergeResolver\Resolvers\ServiceMergeResolver;

class ServiceMergeResolverTest extends Unit
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
        $projectData = [
            'services' => [
                'redis' => null,
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

        $expectedData = [
            'services' => [
                'db' => [
                    'engine' => 'mysql',
                ],
                'redis' => DeployFileGeneratorConstants::YAML_SERVICE_NULL_VALUE,
            ],
        ];

        // Act
        $serviceMergeResolver = new ServiceMergeResolver();
        $resultData = $serviceMergeResolver->resolve($projectData, $importData);

        // Assert
        $this->tester->assertEquals($expectedData, $resultData);

        // Arrange
        $projectData = [
            'region' => [
                'EU' => 'data',
            ],
        ];

        $importData = [
            'region' => [
                'US' => 'data',
            ],
        ];

        $expectedData = [
            'region' => [
                'EU' => 'data',
                'US' => 'data',
            ],
        ];

        // Act
        $resultData = $serviceMergeResolver->resolve($projectData, $importData);

        // Assert
        $this->tester->assertEquals($expectedData, $resultData);
    }
}
