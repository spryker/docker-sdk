<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\MultiStore\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class EntrypointIdentifierExecutor implements DataExecutorInterface
{
//    todo: rename class. Don't understand what the fuck
    public function exec(array $projectData): array
    {
        return $projectData;

//        foreach ($projectData['groups'] ?? [] as $groupName => $groupData) {
//            foreach ($groupData['applications'] ?? [] as $applicationName => $applicationData) {
//                foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {
//                    if ($endpointData === null) {
//                        $endpointData = [];
//                    }
//
//                    $application = $applicationData['application'];
//                    $store = $endpointData['store'] ?? null;
//                    $region = $endpointData['region'] ?? null;
//
//                    $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['identifier'] = $store ? $store : $region;
//
//                    if (!$store && $region && !array_key_exists('redirect', $endpointData)) {
//                        $isPrimal = !empty($endpointData['primal']) || empty($primal[$store][$application]);
//
//                        if ($isPrimal) {
//                            $regionName = $groupData['region'];
//                            $primal[$regionName][$application] = function (&$projectData) use (
//                                $groupName,
//                                $applicationName,
//                                $application,
//                                $endpoint,
//                                $regionName
//                            ) {
//                                $projectData['_endpointMap'][$regionName][$application] = $endpoint;
//                                $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['primal'] = true;
//                            };
//                        }
//                    }
//                }
//            }
//        }
//
//        return $projectData;
    }
}
