<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Executor;

use Codeception\Test\Unit;
use DeployFileGenerator\Executor\ExecutorInterface;
use DeployFileGenerator\Executor\SortResultDataExecutor;
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
        $transfer = $this->createSortResultDataExecutor()->execute($transfer);

        $this->tester->assertEquals(array_keys($exceptedResult), array_keys($transfer->getResultData()));
        $this->tester->assertNotEquals(array_keys($data), array_keys($transfer->getResultData()));
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function createSortResultDataExecutor(): ExecutorInterface
    {
        return new SortResultDataExecutor([
            'first-key',
            'second-key',
            'specific-key',
        ]);
    }
}
