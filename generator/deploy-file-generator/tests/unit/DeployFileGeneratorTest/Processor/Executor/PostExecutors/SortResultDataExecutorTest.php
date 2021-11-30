<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor\Executor\PostExecutors;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorConfig;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Processor\Executor\PostExecutors\SortResultDataExecutor;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class SortResultDataExecutorTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testExecute(): void
    {
        // Arrange
        $data = [
            'third-key' => 'some data',
            'first-key' => 'some data',
            'some-key' => 'some data',
            'second-key' => 'some data',
        ];
        $exceptedResult = [
            'first-key' => 'some data',
            'second-key' => 'some data',
            'third-key' => 'some data',
            'some-key' => 'some data',
        ];

        $transfer = new DeployFileTransfer();
        $transfer = $transfer->setResultData($data);

        // Act
        $transfer = $this->createSortResultDataExecutor()->execute($transfer);

        // Assert
        $this->tester->assertEquals(array_keys($exceptedResult), array_keys($transfer->getResultData()));
        $this->tester->assertNotEquals(array_keys($data), array_keys($transfer->getResultData()));
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    protected function createSortResultDataExecutor(): ExecutorInterface
    {
        return new SortResultDataExecutor(
            $this->makeEmpty(DeployFileGeneratorConfig::class, [
                'getDeployFileOutputOrderKeys' => [
                    'first-key',
                    'second-key',
                    'specific-key',
                ]
            ])
        );
    }
}
