<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Executor;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileFactory;
use DeployFileGenerator\Executor\ExecutorFactory;
use ReflectionMethod;

class ExecutorFactoryTest extends Unit
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
    public function testCreateExportDeployFileTransferToYamlExecutor(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateYamlDeployFileBuildExecutorCollection(): void
    {
        $this->tester->assertIsArray($this->createExecutorFactory()->createYamlDeployFileBuildExecutorCollection());
    }

    /**
     * @return void
     */
    public function testCreateProjectImportDataExecutor(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreateBaseImportDataExecutor(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return void
     */
    public function testCreatePrepareDeployFileTransferExecutor(): void
    {
        $this->assertInstanceOfForThisFactoryMethod();
    }

    /**
     * @return string
     */
    protected function getFactoryMethod(): string
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
        $factoryReflection = new ReflectionMethod(ExecutorFactory::class, $factoryMethod);
        $factoryMethodReturnType = $factoryReflection->getReturnType();

        $resultObject = $this->createExecutorFactory()->$factoryMethod();

        $this->tester->assertInstanceOf($factoryMethodReturnType, $resultObject);
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorFactory
     */
    protected function createExecutorFactory(): ExecutorFactory
    {
        return new ExecutorFactory(new DeployFileFactory());
    }
}
