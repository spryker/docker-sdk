<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSdk\Helpers;

use DockerSdk\DockerSdkConstants;

class ContainerNameBuilder
{
    const TEMPLATE = '%s_%s';

    public static function build(string $serviceName): string
    {
        $sharedServices = DockerSdkConstants::SPRYKER_SHARED_SERVICES_LIST;
        $sharedServices = array_flip($sharedServices);

        if (!array_key_exists($serviceName, $sharedServices)) {
            return sprintf(self::TEMPLATE, DockerSdkConstants::SPRYKER_PROJECT_NAME, $serviceName);
        }

        return sprintf(self::TEMPLATE, DockerSdkConstants::SPRYKER_INTERNAL_PROJECT_NAME, $serviceName);
    }
}
