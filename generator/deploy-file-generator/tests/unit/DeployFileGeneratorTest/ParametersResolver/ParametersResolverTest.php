<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\ParametersResolver;

use Codeception\Test\Unit;
use DeployFileGenerator\ParametersResolver\ParametersResolver;
use DeployFileGenerator\ParametersResolver\Resolvers\ParameterResolverInterface;

class ParametersResolverTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testResolveParams(): void
    {
        // Arrange
        $parametersResolver = new ParametersResolver(
            $this->createResolverCollection(),
        );

        $data = [
            'first-key' => '**data',
            '**key' => 'second data',
            'third-key' => [
                '**additional-key' => '%%additional-data',
            ],
        ];

        $params = [
            'key' => 'second-key',
            'data' => 'first data',
            'additional-key' => 'additional-key',
            'additional-data' => 'additional data',
        ];

        $expected = [
            'first-key' => 'first data',
            'second-key' => 'second data',
            'third-key' => [
                'additional-key' => 'additional data',
            ],
        ];

        // Act
        $result = $parametersResolver->resolveParams($data, $params);

        // Assert
        $this->tester->assertEquals($expected, $result);
    }

    /**
     * @return array
     */
    protected function createResolverCollection(): array
    {
        return [
            $this->makeEmpty(ParameterResolverInterface::class, [
                'resolveValue' => function ($value, array $params = []) {
                    if (substr($value, 0, 2) == '**') {
                        $param = substr($value, 2);

                        return $params[$param] ?? $value;
                    }

                    return $value;
                },
            ]),
            $this->makeEmpty(ParameterResolverInterface::class, [
                'resolveValue' => function ($value, array $params = []) {
                    if (substr($value, 0, 2) == '%%') {
                        $param = substr($value, 2);

                        return $params[$param] ?? $value;
                    }

                    return $value;
                },
            ]),
        ];
    }
}
