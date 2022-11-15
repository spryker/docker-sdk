<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSdk;


class DockerSdkConfig
{
    /**
     * @return array
     */
    public function getSharedServiceList(): array
    {
        return DockerSdkConstants::SPRYKER_SHARED_SERVICES_LIST;
    }

    /**
     * @return string
     */
    public function getInternalProjectName(): string
    {
        return DockerSdkConstants::SPRYKER_INTERNAL_PROJECT_NAME;
    }

    public function getDockerComposeSharedServiceDataFilePath(): string
    {
        return DockerSdkConstants::SPRYKER_DOCKER_SDK_INTERNAL_DEPLOYMENT_DIR
            . DIRECTORY_SEPARATOR
            .DockerSdkConstants::DOCKER_COMPOSE_SHARED_SERVICES_DATA_FILENAME;
    }

    public function getDockerComposeSyncDataFilePath(): string
    {
        return DockerSdkConstants::SPRYKER_DOCKER_SDK_INTERNAL_DEPLOYMENT_DIR
            . DIRECTORY_SEPARATOR
            .DockerSdkConstants::DOCKER_COMPOSE_SYNC_DATA_FILENAME;
    }

    public function getGatewayDataFilePath(): string
    {
        return DockerSdkConstants::SPRYKER_DOCKER_SDK_INTERNAL_DEPLOYMENT_DIR
            . DIRECTORY_SEPARATOR
            . DockerSdkConstants::DOCKER_COMPOSE_GATEWAY_DATA_FILENAME;
    }

    public function getProjectDataFilePath(): string
    {
        return DockerSdkConstants::SPRYKER_DOCKER_SDK_INTERNAL_DEPLOYMENT_DIR
            . DIRECTORY_SEPARATOR
            . DockerSdkConstants::DOCKER_COMPOSE_PROJECTS_DATA_FILENAME;
    }

    public function getRedisDataFilePath(): string
    {
        return DockerSdkConstants::SPRYKER_DOCKER_SDK_INTERNAL_DEPLOYMENT_DIR
            . DIRECTORY_SEPARATOR
            . DockerSdkConstants::DOCKER_COMPOSE_REDIS_DATA_FILENAME;
    }

    public function getProjectDeploymentDir(): string
    {
        return DockerSdkConstants::SPRYKER_DOCKER_SDK_DEPLOYMENT_DIR;
    }

    public function getSprykerProjectPath(): string
    {
        return DockerSdkConstants::SPRYKER_PROJECT_PATH;
    }

    public function getSprykerProjectName(): string
    {
        return DockerSdkConstants::SPRYKER_PROJECT_NAME;
    }
}
