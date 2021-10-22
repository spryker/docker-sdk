<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Executor;

use DeployFileGenerator\DeployFileConstants;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class ImportProjectDataExecutor extends AbstractImportDataExecutor
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return array
     */
    protected function prepareDataToImport(DeployFileTransfer $deployFileTransfer): array
    {
        $data = $deployFileTransfer->getResultData();
        $data[DeployFileConstants::YAML_IMPORTS_KEY] = $deployFileTransfer->getProjectImports();

        return $data;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     * @param array $data
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    protected function setDataIntoDeployFileTransfer(DeployFileTransfer $deployFileTransfer, array $data): DeployFileTransfer
    {
        return $deployFileTransfer->setResultData($data);
    }
}
