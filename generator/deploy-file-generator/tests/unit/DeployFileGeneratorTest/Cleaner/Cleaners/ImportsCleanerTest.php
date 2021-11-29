<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Cleaner\Cleaners;

use Codeception\Test\Unit;
use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\Cleaner\Cleaners\ImportsCleaner;
use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class ImportsCleanerTest extends Unit
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

        $deployFileTransfer = $this->createImportsCleaner()->clean($deployFileTransfer);

        $this->tester->assertEquals($expectedResult, $deployFileTransfer->getResultData());
    }

    /**
     * @return void
     */
    public function testCleanWithoutImportsKeyInResultData(): void
    {
        $resultData = [
            'first-key' => 'some-data',
            'second-key' => 'some-data',
        ];

        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setResultData($resultData);

        $deployFileTransfer = $this->createImportsCleaner()->clean($deployFileTransfer);

        $this->tester->assertEquals($resultData, $deployFileTransfer->getResultData());
    }

    /**
     * @return \DeployFileGenerator\Cleaner\CleanerInterface
     */
    protected function createImportsCleaner(): CleanerInterface
    {
        return new ImportsCleaner();
    }
}
