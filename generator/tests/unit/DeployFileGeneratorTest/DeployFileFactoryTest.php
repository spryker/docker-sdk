<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileFactory;
use ReflectionMethod;

class DeployFileFactoryTest extends Unit
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
    public function testCreateYamlDeployFileProcessor(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateYamlProjectDataImporter(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateYamlDeployFileBuildStrategy(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateYamlDeployFileMergeResolver(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateExecutorFactory(): void
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
    public function testCreateDeployFileBuilder(): void
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
    public function testCreateYamlBaseDataImporter(): void
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
     * @return \DeployFileGenerator\DeployFileFactory
     */
    private function createDeployFileFactory(): DeployFileFactory
    {
        return new DeployFileFactory();
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
        $factoryReflection = new ReflectionMethod(DeployFileFactory::class, $factoryMethod);
        $factoryMethodReturnType = $factoryReflection->getReturnType()->getName();

        $resultObject = $this->createDeployFileFactory()->$factoryMethod();

        $this->tester->assertInstanceOf($factoryMethodReturnType, $resultObject);
    }
}
