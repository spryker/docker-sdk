<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace SharedServices\DataBuilder;

class BrokerDataBuilder implements SharedServiceDataBuilderInterface
{
    public function build(array $data): array
    {

        return $data;
//        todo: should be fixed
        $api = $data['api'] ?? [];

        if (empty($api)) {
            return $api;
        }

        $username = $api['username'] ?? [];
        $password = $api['password'] ?? [];

        return  [
            'api' => [
                'username' => array_unique($username),
                'password' => array_unique($password),
            ],
        ];
    }

    public function getSharedServiceName(): string
    {
        return 'broker';
    }
}
