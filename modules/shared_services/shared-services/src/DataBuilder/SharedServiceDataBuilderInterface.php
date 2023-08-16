<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace SharedServices\DataBuilder;

use DockerSDK\Model\SharedService;

interface SharedServiceDataBuilderInterface
{
    public function build(array $data): array;

    public function getSharedServiceName(): string;
}
