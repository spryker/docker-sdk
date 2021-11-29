<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Cleaner\Cleaners;

use Codeception\Test\Unit;
use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\Cleaner\Cleaners\ServicesCleaner;
use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class ServicesCleanerTest extends Unit
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
        $transfer = $this->createServicesCleaner()->clean($transfer);

        $this->tester->assertEquals($expectedData, $transfer->getResultData());
    }

    /**
     * @return void
     */
    public function testCleanWithoutNullableService(): void
    {
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
        $transfer = $this->createServicesCleaner()->clean($transfer);

        $this->tester->assertEquals($expectedData, $transfer->getResultData());
    }

    /**
     * @return void
     */
    public function testCleanWithoutServices(): void
    {
        $resultData = [
            'some-key' => 'some-data',
        ];
        $expectedData = [
            'some-key' => 'some-data',
        ];
        $transfer = new DeployFileTransfer();
        $transfer = $transfer->setResultData($resultData);
        $transfer = $this->createServicesCleaner()->clean($transfer);

        $this->tester->assertEquals($expectedData, $transfer->getResultData());
    }

    /**
     * @return \DeployFileGenerator\Cleaner\CleanerInterface
     */
    protected function createServicesCleaner(): CleanerInterface
    {
        return new ServicesCleaner();
    }
}
