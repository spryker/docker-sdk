<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace SharedServices\DataBuilder;

use DockerSDK\Model\SharedService;

class RedisGuiDataBuilder implements SharedServiceDataBuilderInterface
{
    public function build(array $data): array
    {
        $hosts = $this->buildHosts($data);
        $services = $this->buildServices($data);

        return [
            'hosts' => $hosts,
            'services' => $services,
        ];
    }

    public function getSharedServiceName(): string
    {
        return 'redis-gui';
    }

    private function buildHosts(array $data): array
    {
        $hosts = $data['hosts'] ?? [];

        if (empty($hosts)) {
            return $hosts;
        }
        $hosts = array_unique($hosts);
        sort($hosts);

        return $hosts;
    }

    private function buildServices(array $data): array
    {
        $services = $data['services'] ?? [];

        if (empty($services)) {
            return $services;
        }

        $result = [];

        foreach ($services as $serviceName => $serviceData) {
            $engine = $serviceData['engine'];

            $result[$serviceName]['engine'] = $engine;

            if (array_key_exists('endpoints', $serviceData)) {
                $endpoints = $serviceData['endpoints'];

                foreach ($endpoints as $endpointName => $endpointData) {
                    if ($endpointData === null) {
                        $result[$serviceName]['endpoints'][$endpointName] = $endpointData;
                        continue;
                    }

                    $protocol = $endpointData['protocol'];

                    $result[$serviceName]['endpoints'][$endpointName] = [
                        'protocol' => $protocol,
                    ];
                }
            }
        }

        return $result;
    }
}
