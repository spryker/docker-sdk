<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor\Executor\PostExecutors;

use Codeception\Test\Unit;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Processor\Executor\PostExecutors\ValidateDeployFileExecutor;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use DeployFileGenerator\Validator\DeployFileValidatorInterface;

class ValidateDeployFileExecutorTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testExecute()
    {
        // Arrange
        $data = [
            'third-key' => 'some data',
            'first-key' => 'some data',
            'some-key' => 'some data',
            'second-key' => 'some data',
        ];

        $transfer = new DeployFileTransfer();
        $transfer = $transfer->setResultData($data);

        // Act
        $transfer = $this->createValidateDeployFileExecutor()->execute($transfer);

        // Assert
        $this->tester->assertEquals(['key' => 'after validation data'], $transfer->getResultData());
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    protected function createValidateDeployFileExecutor(): ExecutorInterface
    {
        return new ValidateDeployFileExecutor($this->makeEmpty(DeployFileValidatorInterface::class, [
            'validate' => function (DeployFileTransfer $deployFileTransfer) {
                return $deployFileTransfer->setResultData([
                    'key' => 'after validation data',
                ]);
            },
        ]));
    }
}
