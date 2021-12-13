<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor\Executor\PostExecutors;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Processor\Executor\PostExecutors\CleanImportsExecutor;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanImportsExecutorTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testCleanWithImportsKeyInResultData(): void
    {
        // Arrange
        $resultData = [
            'some-key' => 'some-data',
            DeployFileGeneratorConstants::YAML_IMPORTS_KEY => [
                1,
                2,
                3,
            ],
        ];
        $expectedResult = [
            'some-key' => 'some-data',
        ];
        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setResultData($resultData);

        // Act
        $deployFileTransfer = $this->createCleanImportsExecutor()->execute($deployFileTransfer);

        // Assert
        $this->tester->assertEquals($expectedResult, $deployFileTransfer->getResultData());
    }

    /**
     * @return void
     */
    public function testCleanWithoutImportsKeyInResultData(): void
    {
        // Arrange
        $resultData = [
            'first-key' => 'some-data',
            'second-key' => 'some-data',
        ];

        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setResultData($resultData);

        // Act
        $deployFileTransfer = $this->createCleanImportsExecutor()->execute($deployFileTransfer);

        // Assert
        $this->tester->assertEquals($resultData, $deployFileTransfer->getResultData());
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    protected function createCleanImportsExecutor(): ExecutorInterface
    {
        return new CleanImportsExecutor();
    }
}
