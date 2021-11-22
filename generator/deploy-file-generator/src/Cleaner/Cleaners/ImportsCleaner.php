<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Cleaner\Cleaners;

use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\DeployFileConstants;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class ImportsCleaner implements CleanerInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function clean(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $resultData = $deployFileTransfer->getResultData();

        if (!array_key_exists(DeployFileConstants::YAML_IMPORTS_KEY, $resultData)) {
            return $deployFileTransfer;
        }

        unset($resultData[DeployFileConstants::YAML_IMPORTS_KEY]);

        return $deployFileTransfer->setResultData($resultData);
    }
}
