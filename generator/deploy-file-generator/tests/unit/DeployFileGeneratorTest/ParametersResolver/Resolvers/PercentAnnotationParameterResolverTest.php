<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\ParametersResolver\Resolvers;

use Codeception\Test\Unit;
use DeployFileGenerator\ParameterFilter\Filters\LowerCaseParameterFilter;
use DeployFileGenerator\ParameterFilter\Filters\UpperCaseParameterFilter;
use DeployFileGenerator\ParametersResolver\Resolvers\PercentAnnotationParameterResolver;

class PercentAnnotationParameterResolverTest extends Unit
{
    /**
     * @var \DeployFileGenerator\ParametersResolver\Resolvers\ParameterResolverInterface
     */
    protected $percentAnnotationParameterResolver;

    /**
     * @return void
     */
    public function setUp(): void
    {
        $this->percentAnnotationParameterResolver = new PercentAnnotationParameterResolver([
            new UpperCaseParameterFilter(),
            new LowerCaseParameterFilter()
        ]);
    }

    /**
     * @return void
     */
    public function testResolveValue(): void
    {
        // Act, Assert
        $this->assertEquals(
            'demo',
            $this->percentAnnotationParameterResolver->resolveValue('%env%', [
                'env' => 'demo',
            ]),
        );

        // Act, Assert
        $this->assertEquals(
            'some-demo-environment',
            $this->percentAnnotationParameterResolver->resolveValue('some-%env%-environment', [
                'env' => 'demo',
            ]),
        );
        // Act, Assert
        $this->assertEquals(
            123,
            $this->percentAnnotationParameterResolver->resolveValue(123, [
                'env' => 'demo',
            ]),
        );

        // Act, Assert
        $this->assertEquals(
            'some-string-without-annotation',
            $this->percentAnnotationParameterResolver->resolveValue('some-string-without-annotation', [
                'env' => 'demo',
            ]),
        );

        // Act, Assert
        $this->assertEquals(
            'some-%env%-environment',
            $this->percentAnnotationParameterResolver->resolveValue('some-%env%-environment', [
                'other-param' => 'demo',
            ]),
        );

        // Act, Assert
        $this->assertEquals(
            'some-UPPERCASE-environment',
            $this->percentAnnotationParameterResolver->resolveValue('some-%env|upper%-environment', [
                'env' => 'uppercase',
            ]),
        );

        // Act, Assert
        $this->assertEquals(
            'some-lowercase-environment',
            $this->percentAnnotationParameterResolver->resolveValue('some-%env|lower%-environment', [
                'env' => 'LoWeRcAsE',
            ]),
        );
    }

    /**
     * @return void
     */
    public function testGetAnnotationTemplate(): void
    {
        // Act, Assert
        $this->assertIsString($this->percentAnnotationParameterResolver->getAnnotationTemplate());
    }
}
