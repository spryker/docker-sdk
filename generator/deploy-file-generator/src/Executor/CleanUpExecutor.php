<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Executor;

use DeployFileGenerator\DeployFileConstants;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanUpExecutor implements ExecutorInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $result = $deployFileTransfer->getResultData();

        if (!array_key_exists(DeployFileConstants::YAML_IMPORTS_KEY, $result)) {
            return $deployFileTransfer;
        }

        unset($result[DeployFileConstants::YAML_IMPORTS_KEY]);

        return $deployFileTransfer->setResultData($result);
    }
}
