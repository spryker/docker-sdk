<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\Executors;

use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class ImportBaseDataExecutor extends AbstractImportDataExecutor
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return array
     */
    protected function prepareDataToImport(DeployFileTransfer $deployFileTransfer): array
    {
        $data = $deployFileTransfer->getResultData();
        $data[DeployFileGeneratorConstants::YAML_IMPORTS_KEY] = $deployFileTransfer->getBaseImports();

        return $data;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     * @param array $data
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    protected function mapDataToResultData(DeployFileTransfer $deployFileTransfer, array $data): DeployFileTransfer
    {
        $projectData = $deployFileTransfer->getResultData();
        $result = $this->mergeResolver->resolve($data, $projectData);

        return $deployFileTransfer->setResultData($result);
    }
}
