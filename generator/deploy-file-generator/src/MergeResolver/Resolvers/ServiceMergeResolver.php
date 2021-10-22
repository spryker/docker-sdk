<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\MergeResolver\Resolvers;

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

        if (!array_key_exists('services', $resultData)) {
            return $resultData;
        }

        $services = $resultData['services'];

        foreach ($services as $serviceName => $serviceParams) {
            if ($serviceParams == null) {
                unset($services[$serviceName]);
            }
        }

        $resultData['services'] = $services;

        return $resultData;
    }
}
