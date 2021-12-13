<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor\Executor\PostExecutors;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Processor\Executor\PostExecutors\CleanServicesExecutor;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanServicesExecutorTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testCleanWithNullableService(): void
    {
        // Arrange
        $resultData = [
            'some-key' => 'some-data',
            DeployFileGeneratorConstants::YAML_SERVICES_KEY => [
                'search' => [
                    'endpoints' => [],
                ],
                'broker' => DeployFileGeneratorConstants::YAML_SERVICE_NULL_VALUE,
            ],
        ];
        $expectedData = [
            'some-key' => 'some-data',
            DeployFileGeneratorConstants::YAML_SERVICES_KEY => [
                'search' => [
                    'endpoints' => [],
                ],
            ],
        ];
        $transfer = new DeployFileTransfer();
        $transfer = $transfer->setResultData($resultData);

        // Act
        $transfer = $this->createCleanServicesExecutor()->execute($transfer);

        // Assert
        $this->tester->assertEquals($expectedData, $transfer->getResultData());
    }

    /**
     * @return void
     */
    public function testCleanWithoutNullableService(): void
    {
        // Arrange
        $resultData = [
            'some-key' => 'some-data',
            DeployFileGeneratorConstants::YAML_SERVICES_KEY => [
                'search' => [
                    'endpoints' => [],
                ],
            ],
        ];
        $expectedData = [
            'some-key' => 'some-data',
            DeployFileGeneratorConstants::YAML_SERVICES_KEY => [
                'search' => [
                    'endpoints' => [],
                ],
            ],
        ];
        $transfer = new DeployFileTransfer();
        $transfer = $transfer->setResultData($resultData);

        // Act
        $transfer = $this->createCleanServicesExecutor()->execute($transfer);

        // Assert
        $this->tester->assertEquals($expectedData, $transfer->getResultData());
    }

    /**
     * @return void
     */
    public function testCleanWithoutServices(): void
    {
        // Arrange
        $resultData = [
            'some-key' => 'some-data',
        ];
        $expectedData = [
            'some-key' => 'some-data',
        ];
        $transfer = new DeployFileTransfer();
        $transfer = $transfer->setResultData($resultData);

        // Act
        $transfer = $this->createCleanServicesExecutor()->execute($transfer);

        // Assert
        $this->tester->assertEquals($expectedData, $transfer->getResultData());
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    protected function createCleanServicesExecutor(): ExecutorInterface
    {
        return new CleanServicesExecutor();
    }
}
