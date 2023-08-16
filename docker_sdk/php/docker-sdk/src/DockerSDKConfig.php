<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSDK;

use SharedServices\SharedServicesConstant;
use Symfony\Component\Yaml\Parser;


class DockerSDKConfig
{
    protected Parser $ymlReader;

    /**
     * @param Parser $ymlReader
     */
    public function __construct(Parser $ymlReader)
    {
        $this->ymlReader = $ymlReader;
    }

    /**
     * @return array
     */
    public function getYmlConfig(): array
    {
        return $this->ymlReader->parseFile($this->getDockerSdkConfigPath());
    }

    public function getDataPath(): string
    {
//        todo: env variable or config
        return '/sdk/data';
    }

    public function getDeploymentPath(): string
    {
//        todo: env variable or config
        return '/sdk/deployment';
    }


    /**
     * @return string
     */
    public function getDockerSdkConfigPath(): string
    {
        return $this->getDataPath() . '/config.yml';
    }


    public function getDockerSdkProjectName(): string
    {
        $config = $this->getYmlConfig();

        return $config[DockerSDKConstant::PROJECT_NAME];
    }

    public function getDockerSdkNetworkList(): array
    {
        $config = $this->getYmlConfig();

        return $config[DockerSDKConstant::DOCKER][DockerSDKConstant::NETWORKS];
    }


    public function getSqlConnectionConfig(): array
    {
        return [
            'driver' => 'sqlite',
            'database' => sprintf(
                '%s/%s.db',
                $this->getDataPath(),
                $this->getDockerSdkProjectName()
            )
        ];
    }
}
