<?php


namespace DeployFileGenerator;

class DeployFileConfig
{
    /**
     * @var string
     */
    protected const PROJECT_DEPLOY_FILE_DIRECTORY_PATH = './deployment/project-deploy-templates/';
    /**
     * @var string
     */
    protected const BASE_DEPLOY_FILE_DIRECTORY_PATH = './deploy-file-generator/templates/';

    /**
     * @return string
     */
    public function getProjectDirectoryPath(): string
    {
        return static::PROJECT_DEPLOY_FILE_DIRECTORY_PATH;
    }

    /**
     * @return string
     */
    public function getBaseDirectoryPath(): string
    {
        return static::BASE_DEPLOY_FILE_DIRECTORY_PATH;
    }

    /**
     * @return int
     */
    public function getYamlInline(): int
    {
        return 50;
    }
}
