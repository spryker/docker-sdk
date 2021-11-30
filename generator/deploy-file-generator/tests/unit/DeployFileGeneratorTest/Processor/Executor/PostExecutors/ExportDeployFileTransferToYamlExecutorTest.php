<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor\Executor\PostExecutors;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorConfig;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Processor\Executor\PostExecutors\ExportDeployFileTransferToYamlExecutor;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Yaml\Dumper;
use Symfony\Component\Yaml\Parser;

class ExportDeployFileTransferToYamlExecutorTest extends Unit
{
    /**
     * @var string
     */
    protected const EXPORT_FILE_PATH = './deploy-file-generator/tests/_output/ExportDeployFileTransferToYamlExecutorTest.yml';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    protected function _after(): void
    {
        unlink(static::EXPORT_FILE_PATH);
    }

    /**
     * @return void
     */
    public function testExecute(): void
    {
        // Arrange, Act
        $deployFileTransfer = $this->createExportDeployFileTransferToYamlExecutor()
            ->execute($this->createDeployFileTransfer());

        // Assert
        $this->tester->assertFileExists(static::EXPORT_FILE_PATH);
        $this->tester->assertEquals(
            $this->getResultData(),
            $this->createParser()->parseFile($deployFileTransfer->getOutputFilePath()),
        );
    }

    /**
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    protected function createDeployFileTransfer(): DeployFileTransfer
    {
        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setResultData($this->getResultData());

        return $deployFileTransfer->setOutputFilePath(static::EXPORT_FILE_PATH);
    }

    /**
     * @return array<string>
     */
    protected function getResultData(): array
    {
        return [
            'some-data' => 'some-value',
        ];
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    protected function createExportDeployFileTransferToYamlExecutor(): ExecutorInterface
    {
        return new ExportDeployFileTransferToYamlExecutor(
            new Dumper(),
            $this->makeEmpty(DeployFileGeneratorConfig::class, [
                'getYamlInline' => 50,
            ])
        );
    }

    /**
     * @return \Symfony\Component\Yaml\Parser
     */
    protected function createParser(): Parser
    {
        return new Parser();
    }
}
