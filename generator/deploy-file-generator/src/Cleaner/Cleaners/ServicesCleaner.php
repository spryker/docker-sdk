<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Cleaner\Cleaners;

use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\DeployFileGeneratorConstants;
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

        if (!array_key_exists(DeployFileGeneratorConstants::YAML_SERVICES_KEY, $resultData)) {
            return $deployFileTransfer;
        }

        foreach ($resultData[DeployFileGeneratorConstants::YAML_SERVICES_KEY] as $serviceName => $serviceConfig) {
            if ($serviceConfig == DeployFileGeneratorConstants::YAML_SERVICE_NULL_VALUE) {
                unset($resultData[DeployFileGeneratorConstants::YAML_SERVICES_KEY][$serviceName]);
            }
        }

        return $deployFileTransfer->setResultData($resultData);
    }
}
