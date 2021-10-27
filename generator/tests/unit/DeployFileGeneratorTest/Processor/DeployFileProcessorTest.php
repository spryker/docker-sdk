<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGeneratorTest\Processor;

use Codeception\Test\Unit;
use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Strategy\DeployFileBuildStrategyInterface;
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
        $processor = new DeployFileProcessor(
            $this->createStrategyMock()
        );
        $deployFileTransfer = new DeployFileTransfer();

        $this->tester->assertIsEmpty($deployFileTransfer->getRawData());

        $deployFileTransfer = $processor->process($deployFileTransfer);

        $this->tester->assertEquals([
            static::NEW_KEY => static::NEW_DATA,
        ], $deployFileTransfer->getRawData());
    }

    /**
     * @return \DeployFileGenerator\Strategy\DeployFileBuildStrategyInterface
     */
    protected function createStrategyMock(): DeployFileBuildStrategyInterface
    {
        return $this->makeEmpty(DeployFileBuildStrategyInterface::class, [
            'execute' => function (DeployFileTransfer $deployFileTransfer) {
                $newRawData = $deployFileTransfer->getRawData();
                $newRawData[static::NEW_KEY] = static::NEW_DATA;

                return $deployFileTransfer->setRawData($newRawData);
            },
        ]);
    }
}
