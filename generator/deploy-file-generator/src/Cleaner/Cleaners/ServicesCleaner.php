<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Cleaner\Cleaners;

use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\DeployFileConstants;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class ServicesCleaner implements CleanerInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function clean(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $resultData = $deployFileTransfer->getResultData();

        if (!array_key_exists(DeployFileConstants::YAML_SERVICES_KEY, $resultData)) {
            return $deployFileTransfer;
        }

        foreach ($resultData[DeployFileConstants::YAML_SERVICES_KEY] as $serviceName => $serviceConfig) {
            if ($serviceConfig == DeployFileConstants::YAML_SERVICE_NULL_VALUE) {
                unset($resultData[DeployFileConstants::YAML_SERVICES_KEY][$serviceName]);
            }
        }

        return $deployFileTransfer->setResultData($resultData);
    }
}
