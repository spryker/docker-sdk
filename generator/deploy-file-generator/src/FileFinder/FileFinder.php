<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\FileFinder;

use DeployFileGenerator\DeployFileConfig;

class FileFinder implements FileFinderInterface
{
    /**
     * @var \DeployFileGenerator\DeployFileConfig
     */
    protected $config;

    /**
     * @param \DeployFileGenerator\DeployFileConfig $config
     */
    public function __construct(DeployFileConfig $config)
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
            $this->buildPath($this->config->getBaseDirectoryPath()) . $fileName
        );
    }

    /**
     * @param string $fileName
     *
     * @return string
     */
    public function getFilePathOnProjectLayer(string $fileName): ?string
    {
        return $this->getFilePath(
            $this->buildPath($this->config->getProjectDirectoryPath()) . $fileName
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
