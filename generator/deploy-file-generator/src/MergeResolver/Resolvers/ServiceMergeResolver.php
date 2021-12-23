<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\MergeResolver\Resolvers;

use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;

class ServiceMergeResolver implements MergeResolverInterface
{
    /**
     * @param array $projectData
     * @param array $importData
     *
     * @return array
     */
    public function resolve(array $projectData, array $importData): array
    {
        $resultData = array_replace_recursive($importData, $projectData);

        if (!array_key_exists(DeployFileGeneratorConstants::YAML_SERVICES_KEY, $resultData)) {
            return $resultData;
        }

        $services = $resultData[DeployFileGeneratorConstants::YAML_SERVICES_KEY];

        foreach ($services as $serviceName => $serviceParams) {
            if ($serviceParams == null) {
                $services[$serviceName] = DeployFileGeneratorConstants::YAML_SERVICE_NULL_VALUE;
            }
        }

        $resultData[DeployFileGeneratorConstants::YAML_SERVICES_KEY] = $services;

        return $resultData;
    }
}
