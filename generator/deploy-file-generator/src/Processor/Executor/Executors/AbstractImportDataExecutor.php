<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\Executors;

use DeployFileGenerator\Importer\DeployFileImporterInterface;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

abstract class AbstractImportDataExecutor implements ExecutorInterface
{
    /**
     * @var \DeployFileGenerator\Importer\DeployFileImporterInterface
     */
    protected $importer;

    /**
     * @var \DeployFileGenerator\MergeResolver\MergeResolverInterface
     */
    protected $mergeResolver;

    /**
     * @param \DeployFileGenerator\Importer\DeployFileImporterInterface $importer
     * @param \DeployFileGenerator\MergeResolver\MergeResolverInterface $mergeResolver
     */
    public function __construct(DeployFileImporterInterface $importer, MergeResolverInterface $mergeResolver)
    {
        $this->importer = $importer;
        $this->mergeResolver = $mergeResolver;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $data = $this->prepareDataToImport($deployFileTransfer);
        $data = $this->importer->importFromData($data);
        $deployFileTransfer = $this->mapDataToResultData($deployFileTransfer, $data);

        return $deployFileTransfer;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return array
     */
    abstract protected function prepareDataToImport(DeployFileTransfer $deployFileTransfer): array;

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     * @param array $data
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    abstract protected function mapDataToResultData(DeployFileTransfer $deployFileTransfer, array $data): DeployFileTransfer;
}
