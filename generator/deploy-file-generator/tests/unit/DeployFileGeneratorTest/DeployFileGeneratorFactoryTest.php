<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorFactory;
use ReflectionMethod;

class DeployFileGeneratorFactoryTest extends Unit
{
    /**
     * @var string
     */
    protected const FUNCTION_KEY = 'function';

    /**
     * @var string
     */
    protected const TEST_PREFIX = 'test';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testCreateProjectDataImporter(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateDeployFileMergeResolver(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateFileFinder(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateSymfonyYamlDumper(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testGetMergeResolverCollection(): void
    {
        $this->tester->assertIsArray($this->createDeployFileFactory()->getMergeResolverCollection());
    }

    /**
     * @return void
     */
    public function testCreateSymfonyYamlParser(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateBaseDataImporter(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testGetParameterResolverCollection(): void
    {
        $this->tester->assertIsArray($this->createDeployFileFactory()->getParameterResolverCollection());
    }

    /**
     * @return void
     */
    public function testCreateParametersResolver(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateDeployFileConfig(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateDeployFileOutput(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return \DeployFileGenerator\DeployFileGeneratorFactory
     */
    private function createDeployFileFactory(): DeployFileGeneratorFactory
    {
        return new DeployFileGeneratorFactory();
    }

    /**
     * @return string
     */
    private function getFactoryMethod(): string
    {
        $testMethodName = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 4)[2][static::FUNCTION_KEY];

        return lcfirst(ltrim($testMethodName, static::TEST_PREFIX));
    }

    /**
     * @return void
     */
    protected function assertInstanceOfForThisFactoryMethod(): void
    {
        $factoryMethod = $this->getFactoryMethod();
        $factoryReflection = new ReflectionMethod(DeployFileGeneratorFactory::class, $factoryMethod);
        $factoryMethodReturnType = $factoryReflection->getReturnType();

        $resultObject = $this->createDeployFileFactory()->$factoryMethod();

        $this->tester->assertInstanceOf($factoryMethodReturnType, $resultObject);
    }
}
