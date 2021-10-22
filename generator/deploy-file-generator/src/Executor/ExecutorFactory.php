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
     * @return \DeployFileGenerator\Executor\ExecutorInterface[]
     */
    public function createYamlDeployFileBuildExecutorCollection(): array
    {
        return [
            $this->createPrepareDeployFileTransferExecutor(),
            $this->createProjectImportDataExecutor(),
            $this->createBaseImportDataExecutor(),
            $this->createCleanUpExecutor(),
            $this->createExportDeployFileTransferToYamlExecutor(),
        ];
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createPrepareDeployFileTransferExecutor(): ExecutorInterface
    {
        return new PrepareDeployFileTransferExecutor(
            $this->deployFileFactory->createSymfonyYamlParser(),
            $this->deployFileFactory->createFileFinder()
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createExportDeployFileTransferToYamlExecutor(): ExecutorInterface
    {
        return new ExportDeployFileTransferToYamlExecutor(
            $this->deployFileFactory->createSymfonyYamlDumper(),
            $this->deployFileFactory->createDeployFileConfig()->getYamlInline()
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createProjectImportDataExecutor(): ExecutorInterface
    {
        return new ImportProjectDataExecutor(
            $this->deployFileFactory->createYamlProjectDataImporter(),
            $this->deployFileFactory->createYamlDeployFileMergeResolver()
        );
    }

    /**
     * @return \DeployFileGenerator\Executor\ExecutorInterface
     */
    public function createBaseImportDataExecutor(): ExecutorInterface
    {
        return new ImportBaseDataExecutor(
            $this->deployFileFactory->createYamlBaseDataImporter(),
            $this->deployFileFactory->createYamlDeployFileMergeResolver()
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
