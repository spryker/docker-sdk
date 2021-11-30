<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\PostExecutors;

use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanServicesExecutor implements ExecutorInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
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
