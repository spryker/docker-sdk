<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Executor;

use DeployFileGenerator\DeployFileFactory;

class ExecutorFactory
{
    /**
     * @var \DeployFileGenerator\DeployFileFactory
     */
    protected $deployFileFactory;

    /**
     * @param \DeployFileGenerator\DeployFileFactory $deployFileFactory
     */
    public function __construct(DeployFileFactory $deployFileFactory)
    {
        $this->deployFileFactory = $deployFileFactory;
    }

    /**
     * @return array<\DeployFileGenerator\Executor\ExecutorInterface>
     */
    public function createYamlDeployFileBuildExecutorCollection(): array
    {
        return [
            $this->createPrepareDeployFileTransferExecutor(),
            $this->createProjectImportDataExecutor(),
            $this->createBaseImportDataExecutor(),
            $this->createCleanUpExecutor(),
            $this->createExportDeployFileTransferToYamlExecutor(),
            $this->createValidateDeployFileExecutor(),
        ];
    }

    /**
     * @return array<\DeployFileGenerator\Executor\ExecutorInterface>
     */
    public function createYamlDeployFileConfigExecutorCollection(): array
    {
        return [
            $this->createPrepareDeployFileTransferExecutor(),
            $this->createProjectImportDataExecutor(),
            $this->createBaseImportDataExecutor(),
            $this->createCleanUpExecutor(),
            $this->createValidateDeployFileExecutor(),
        ];
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function createPrepareDeployFileTransferExecutor(): ExecutorInterface
    {
        return new PrepareDeployFileTransferExecutor(
            $this->deployFileFactory->createSymfonyYamlParser(),
            $this->deployFileFactory->createFileFinder(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function createExportDeployFileTransferToYamlExecutor(): ExecutorInterface
    {
        return new ExportDeployFileTransferToYamlExecutor(
            $this->deployFileFactory->createSymfonyYamlDumper(),
            $this->deployFileFactory->createDeployFileConfig()->getYamlInline(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function createProjectImportDataExecutor(): ExecutorInterface
    {
        return new ImportProjectDataExecutor(
            $this->deployFileFactory->createYamlProjectDataImporter(),
            $this->deployFileFactory->createYamlDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function createBaseImportDataExecutor(): ExecutorInterface
    {
        return new ImportBaseDataExecutor(
            $this->deployFileFactory->createYamlBaseDataImporter(),
            $this->deployFileFactory->createYamlDeployFileMergeResolver(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function createValidateDeployFileExecutor(): ExecutorInterface
    {
        return new ValidateDeployFileExecutor(
            $this->deployFileFactory->createValidatorFactory()->createValidator(),
            $this->deployFileFactory->createDeployFileConfig()->getValidationRulesFilePath(),
            $this->deployFileFactory->createSymfonyYamlParser(),
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    protected function createCleanUpExecutor(): ExecutorInterface
    {
        return new CleanUpExecutor();
    }
}
