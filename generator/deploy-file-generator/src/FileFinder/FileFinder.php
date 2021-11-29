<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\FileFinder;

use DeployFileGenerator\DeployFileGeneratorConfig;

class FileFinder implements FileFinderInterface
{
    /**
     * @var \DeployFileGenerator\DeployFileGeneratorConfig
     */
    protected $config;

    /**
     * @param \DeployFileGenerator\DeployFileGeneratorConfig $config
     */
    public function __construct(DeployFileGeneratorConfig $config)
    {
        $this->config = $config;
    }

    /**
     * @param string $fileName
     *
     * @return string|null
     */
    public function getFilePathOnBaseLayer(string $fileName): ?string
    {
        return $this->getFilePath(
            $this->buildPath($this->config->getBaseDirectoryPath()) . $fileName,
        );
    }

    /**
     * @param string $fileName
     *
     * @return string|null
     */
    public function getFilePathOnProjectLayer(string $fileName): ?string
    {
        return $this->getFilePath(
            $this->buildPath($this->config->getProjectDirectoryPath()) . $fileName,
        );
    }

    /**
     * @param string $path
     *
     * @return string
     */
    protected function buildPath(string $path): string
    {
        return rtrim($path, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR;
    }

    /**
     * @param string $filePath
     *
     * @return string|null
     */
    protected function getFilePath(string $filePath): ?string
    {
        return file_exists($filePath) ? $filePath : null;
    }
}
