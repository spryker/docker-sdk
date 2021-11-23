<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Cleaner;

use Codeception\Test\Unit;
use DeployFileGenerator\Cleaner\Cleaner;
use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanerTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testClean(): void
    {
        $resultData = [
            'first-key' => 'some-data',
            'second-key' => 'some-data',
            'third-key' => 'some-data',
        ];

        $expectedData = [
            'second-key' => 'some-data',
        ];
        $transfer = new DeployFileTransfer();
        $transfer = $transfer->setResultData($resultData);

        $cleaner = $this->createCleaner();

        $transfer = $cleaner->clean($transfer);

        $this->tester->assertEquals($expectedData, $transfer->getResultData());
    }

    /**
     * @return \DeployFileGenerator\Cleaner\CleanerInterface
     */
    protected function createCleaner(): CleanerInterface
    {
        return new Cleaner([
            $this->makeEmpty(CleanerInterface::class, [
                'clean' => function (DeployFileTransfer $deployFileTransfer) {
                    $resultData = $deployFileTransfer->getResultData();

                    if (array_key_exists('first-key', $resultData)) {
                        unset($resultData['first-key']);
                    }

                    return $deployFileTransfer->setResultData($resultData);
                }]),
            $this->makeEmpty(CleanerInterface::class, [
                'clean' => function (DeployFileTransfer $deployFileTransfer) {
                    $resultData = $deployFileTransfer->getResultData();

                    if (array_key_exists('third-key', $resultData)) {
                        unset($resultData['third-key']);
                    }

                    return $deployFileTransfer->setResultData($resultData);
                }]),
        ]);
    }
}
