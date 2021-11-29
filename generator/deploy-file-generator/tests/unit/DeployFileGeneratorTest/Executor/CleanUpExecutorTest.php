<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Executor;

use Codeception\Test\Unit;
use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Executor\CleanUpExecutor;
use DeployFileGenerator\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanUpExecutorTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testExecuteWithImportsKeyInResultData(): void
    {
        $resultData = [
            'some-key' => 'some-data',
            DeployFileGeneratorConstants::YAML_IMPORTS_KEY => [
                1,
                2,
                3,
            ],
        ];

        $deployFileTransfer = $this->getCleanUpExecutor()->execute(
            $this->createDeployFileTransferWithResultData($resultData),
        );

        $this->tester->assertArrayNotHasKey(
            DeployFileGeneratorConstants::YAML_IMPORTS_KEY,
            $deployFileTransfer->getResultData(),
        );
    }

    /**
     * @return void
     */
    public function testExecuteWithoutImportsKeyInResultData(): void
    {
        $resultData = [
            'some-key' => 'some-data',
        ];

        $deployFileTransfer = $this->getCleanUpExecutor()->execute(
            $this->createDeployFileTransferWithResultData($resultData),
        );

        $this->tester->assertArrayNotHasKey(
            DeployFileGeneratorConstants::YAML_IMPORTS_KEY,
            $deployFileTransfer->getResultData(),
        );
    }

    /**
     * @param array $resultData
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    protected function createDeployFileTransferWithResultData(array $resultData): DeployFileTransfer
    {
        $deployFileTransfer = new DeployFileTransfer();

        return $deployFileTransfer->setResultData($resultData);
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function getCleanUpExecutor(): ExecutorInterface
    {
        return new CleanUpExecutor($this->makeEmpty(
            CleanerInterface::class,
            [
            'clean' => function (DeployFileTransfer $deployFileTransfer) {
                $resultData = $deployFileTransfer->getResultData();

                if (!array_key_exists(DeployFileGeneratorConstants::YAML_IMPORTS_KEY, $resultData)) {
                    return $deployFileTransfer;
                }

                unset($resultData[DeployFileGeneratorConstants::YAML_IMPORTS_KEY]);

                $deployFileTransfer = $deployFileTransfer->setResultData($resultData);

                return $deployFileTransfer;
            }],
        ));
    }
}
