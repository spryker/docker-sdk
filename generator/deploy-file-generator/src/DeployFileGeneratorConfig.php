<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator;

class DeployFileGeneratorConfig
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
     * @var string
     */
    protected const VALIDATION_RULES_FILE_PATH = './deploy-file-generator/config/validation.yml';

    /**
     * @var array<string>
     */
    protected const DEPLOY_FILE_KEY_ORDER = [
        'version',
        'namespace',
        'tag',
        'environment',
        'image',
        'composer',
        'assets',
        'regions',
        'groups',
        'services',
        'docker',
    ];

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

    /**
     * @return string
     */
    public function getValidationRulesFilePath(): string
    {
        return static::VALIDATION_RULES_FILE_PATH;
    }

    /**
     * @return array<string>
     */
    public function getDeployFileOutputOrderKeys(): array
    {
        return static::DEPLOY_FILE_KEY_ORDER;
    }
}
