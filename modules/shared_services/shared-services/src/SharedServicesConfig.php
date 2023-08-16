<?php


namespace SharedServices;


use DockerSDK\DockerSDKConfig;
use Exception;

class SharedServicesConfig extends DockerSDKConfig
{
    /**
     * @return array
     */
    public function getSharedServiceList(): array
    {
        $config = $this->getYmlConfig();

        return $config[SharedServicesConstant::SHARED_SERVICES];
    }

    public function getTemplatesPath(): string
    {
        return '/sdk/templates';
    }
}

