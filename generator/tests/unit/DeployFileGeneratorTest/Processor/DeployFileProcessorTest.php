<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor;

use Codeception\Test\Unit;
use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Strategy\DeployFileStrategyInterface;
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
        $deployFileTransfer = new DeployFileTransfer();

        $this->tester->assertIsEmpty($deployFileTransfer->getRawData());

        $deployFileTransfer = $this->createDeployFileProcessor()->process($deployFileTransfer);

        $this->tester->assertEquals([
            static::NEW_KEY => static::NEW_DATA,
        ], $deployFileTransfer->getRawData());
    }

    /**
     * @return \DeployFileGenerator\Strategy\DeployFileStrategyInterface
     */
    protected function createStrategyMock(): DeployFileStrategyInterface
    {
        return $this->makeEmpty(DeployFileStrategyInterface::class, [
            'execute' => function (DeployFileTransfer $deployFileTransfer) {
                $newRawData = $deployFileTransfer->getRawData();
                $newRawData[static::NEW_KEY] = static::NEW_DATA;

                return $deployFileTransfer->setRawData($newRawData);
            },
        ]);
    }

    /**
     * @return \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    protected function createDeployFileProcessor(): DeployFileProcessorInterface
    {
        return new DeployFileProcessor(
            $this->createStrategyMock()
        );
    }
}
