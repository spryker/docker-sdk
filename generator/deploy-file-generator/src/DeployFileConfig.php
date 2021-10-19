<?php

namespace DeployFileGenerator;

class DeployFileConfig
{
    /*todo: one path*/
    protected const PROJECT_DEPLOY_FILE_DIRECTORY_PATH = './deployment/deploy-templates/';
    protected const BASE_DEPLOY_FILE_DIRECTORY_PATH = './deploy-file-generator/templates/';

    /**
     * @return string
     */
    public function getProjectDirectoryPath(): string
    {
        return $this->buildPath(static::PROJECT_DEPLOY_FILE_DIRECTORY_PATH);
    }

    /**
     * @return string
     */
    public function getBaseDirectoryPath(): string
    {
        return $this->buildPath(static::BASE_DEPLOY_FILE_DIRECTORY_PATH);
    }

    /**
     * @return int
     */
    public function getYamlInline(): int
    {
        /*todo: max value?*/
        return 50;
    }

    /**
     * @param string $path
     *
     * @return string
     */
    private function buildPath(string $path): string
    {
        return rtrim($path, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR;
    }
}
