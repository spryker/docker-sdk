<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\ParametersResolver\Resolvers;

use Codeception\Test\Unit;
use DeployFileGenerator\ParametersResolver\Resolvers\PercentAnnotationParameterResolver;

class PercentAnnotationParameterResolverTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testResolveValue(): void
    {
        $percentAnnotationParameterResolver = new PercentAnnotationParameterResolver();
        $this->assertEquals(
            'demo',
            $percentAnnotationParameterResolver->resolveValue('%env%', [
                'env' => 'demo',
            ])
        );

        $this->assertEquals(
            'some-demo-environment',
            $percentAnnotationParameterResolver->resolveValue('some-%env%-environment', [
                'env' => 'demo',
            ])
        );

        $this->assertEquals(
            123,
            $percentAnnotationParameterResolver->resolveValue(123, [
                'env' => 'demo',
            ])
        );

        $this->assertEquals(
            'some-string-without-annotation',
            $percentAnnotationParameterResolver->resolveValue('some-string-without-annotation', [
                'env' => 'demo',
            ])
        );

        $this->assertEquals(
            'some-%env%-environment',
            $percentAnnotationParameterResolver->resolveValue('some-%env%-environment', [
                'other-param' => 'demo',
            ])
        );
    }

    /**
     * @return void
     */
    public function testGetAnnotationTemplate(): void
    {
        $percentAnnotationParameterResolver = new PercentAnnotationParameterResolver();

        $this->tester->assertIsString($percentAnnotationParameterResolver->getAnnotationTemplate());
    }
}
