<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor;

use Codeception\Test\Unit;
use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class DeployFileProcessorTest extends Unit
{
    /**
     * @var string
     */
    protected const NEW_KEY = 'some_key';

    /**
     * @var string
     */
    protected const NEW_DATA = 'some data';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testProcess(): void
    {
        // Arrange
        $deployFileTransfer = new DeployFileTransfer();

        // Assert
        $this->tester->assertIsEmpty($deployFileTransfer->getRawData());

        // Act
        $deployFileTransfer = $this->createDeployFileProcessor()->process($deployFileTransfer);

        // Assert
        $this->tester->assertEquals([
            static::NEW_KEY => static::NEW_DATA,
        ], $deployFileTransfer->getRawData());
    }

    /**
     * @return \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    protected function createDeployFileProcessor(): DeployFileProcessorInterface
    {
        return (new DeployFileProcessor())->addExecutor(
            $this->makeEmpty(
                ExecutorInterface::class,
                [
                    'execute' => function (DeployFileTransfer $deployFileTransfer) {
                        $newRawData = $deployFileTransfer->getRawData();
                        $newRawData[static::NEW_KEY] = static::NEW_DATA;

                        return $deployFileTransfer->setRawData($newRawData);
                    },
                ],
            ),
        );
    }
}
