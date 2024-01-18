<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData\DataBuilder\ProjectData\Executor;

use ProjectData\DataBuilder\DataExecutor\DataExecutorInterface;

class GatewayExecutor implements DataExecutorInterface
{
    public function exec(array $projectData): array
    {
        $entrypoint = $projectData['docker']['ssl']['enabled'] ? 'websecure' : 'web';
        $result = [
            'services' => [],
            'routers' => [],
        ];

        $result['services'][$projectData['namespace'] . '_frontend']['urls'][] = 'http://' . $projectData['namespace'] . '_frontend_1:80';

        foreach ($projectData['groups'] as $group) {
            foreach ($group['applications'] as $applicationName => $applicationData) {
                if ($applicationData['application'] != 'static') {
                    $hosts = [];

                    foreach ($applicationData['endpoints'] as $endpoint => $endpointData) {
                        $hosts[] = 'Host(`' . $endpoint . '`)';;
                    }

                    $result['routers'][$projectData['namespace'] . '_' . $applicationName]['rule'] = implode(' || ', $hosts);
                    $result['routers'][$projectData['namespace'] . '_' . $applicationName]['entrypoints'][] = $entrypoint;
                    $result['routers'][$projectData['namespace'] . '_' . $applicationName]['service'] = $projectData['namespace'] . '_frontend';

                    if ($entrypoint == 'websecure') {
                        $result['routers'][$projectData['namespace'] . '_' . $applicationName]['tls'] = true;
                    }
                }
            }
        }

        $servicePortMap = $this->getServicePortMap();

        foreach ($projectData['services'] as $serviceName => $serviceData) {
            if (!array_key_exists('endpoints', $serviceData)) {
                continue;
            }

            $projectServiceName = $projectData['namespace'] . '_' . $serviceName;
            $hosts = [];


            foreach ($serviceData['endpoints'] as $endpoint => $endpointData) {
                if (is_array($endpointData) && array_key_exists('protocol', $endpointData) && $endpointData['protocol'] == 'tcp') {
                    continue;
                }

                $hosts[] = 'Host(`' . $endpoint . '`)';
            }

            if (empty($hosts)) {
                continue;
            }

            $port = $servicePortMap[$serviceName];
            $url = 'http://' . $projectServiceName . '_1:' . $port;

            $result['services'][$projectServiceName]['urls'][] = $url;

            $result['routers'][$projectServiceName]['rule'] = implode(' || ', $hosts);
            $result['routers'][$projectServiceName]['entrypoints'][] = $entrypoint;
            $result['routers'][$projectServiceName]['service'] = $projectServiceName;

            if ($entrypoint == 'websecure') {
                $result['routers'][$projectServiceName]['tls'] = true;
            }
        }

        $projectData['_gateway'] = $result;

        return $projectData;
    }

    private function getServicePortMap(): array
    {
        return [
            'dashboard' => 3000,
            'scheduler' => 8080,
            'kibana' => 5601,
            'mail_catcher' => 8025,
            'broker' => 15672,
            'redis-gui' => 8081,
            'swagger' => 8082,
        ];
    }
}
