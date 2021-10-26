<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGeneratorTest\MergeResolver\Resolvers;

use Codeception\Test\Unit;
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
            ],
        ];

        $serviceMergeResolver = new ServiceMergeResolver();
        $resultData = $serviceMergeResolver->resolve($projectData, $importData);

        $this->tester->assertEquals($expectedData, $resultData);

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
        $resultData = $serviceMergeResolver->resolve($projectData, $importData);

        $this->tester->assertEquals($expectedData, $resultData);
    }
}
