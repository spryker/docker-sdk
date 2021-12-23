<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\PostExecutors;

use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanImportsExecutor implements ExecutorInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $resultData = $deployFileTransfer->getResultData();

        if (!array_key_exists(DeployFileGeneratorConstants::YAML_IMPORTS_KEY, $resultData)) {
            return $deployFileTransfer;
        }

        unset($resultData[DeployFileGeneratorConstants::YAML_IMPORTS_KEY]);

        return $deployFileTransfer->setResultData($resultData);
    }
}
