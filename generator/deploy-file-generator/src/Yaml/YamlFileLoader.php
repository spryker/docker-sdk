<?php

namespace DeployFileGenerator\Yaml;

use Symfony\Component\Config\Loader\FileLoader;
use Symfony\Component\Yaml\Yaml;

class YamlFileLoader extends FileLoader
{
    protected const PROJECT_DEPLOY_FILE_DIRECTORY_PATH = './deployment/deploy-templates/';
    protected const BASE_DEPLOY_FILE_DIRECTORY_PATH = './deploy-file-generator/templates/';

    /**
     * @param mixed $resource
     * @param null $type
     *
     * @return array
     */
    public function load($resource, $type = null): array
    {
        $content = $this->parseYaml($resource);

        return $this->parseImports($content);
    }

    /**
     * @param mixed $resource
     * @param string|null $type
     * @return bool
     */
    public function supports($resource, string $type = null): bool
    {
        $availableFormats = ['yaml', 'yml'];

        if (!\is_string($resource)) {
            return false;
        }

        if (null === $type && \in_array(pathinfo($resource, \PATHINFO_EXTENSION), $availableFormats, true)) {
            return true;
        }

        return \in_array($type, $availableFormats, true);
    }

    /**
     * @param array $content
     *
     * @return array
     */
    private function parseImports(array $content): array
    {
        if (!array_key_exists('imports', $content)) {
            return $content;
        }

        foreach ($content['imports'] as $import) {
            foreach ($this->getImportFilePaths($import) as $importFilePath) {
                $data = $this->load($importFilePath);
                $content = array_merge($content, $data);
            }
        }

        unset($content['imports']);

        return $content;
    }

    /**
     * @param string $resource
     *
     * @return array
     */
    private function parseYaml(string $resource): array
    {
        $result = Yaml::parseFile($resource);

        if ($result === null) {
            return [];
        }

        return $result;
    }

    /**
     * @param string $import
     * @return string[]
     */
    private function getImportFilePaths(string $import): array
    {
        $importPaths = [];

        $baseDeployFilePath = static::BASE_DEPLOY_FILE_DIRECTORY_PATH . DIRECTORY_SEPARATOR . $import;
        $projectDeployFilePath = static::PROJECT_DEPLOY_FILE_DIRECTORY_PATH . DIRECTORY_SEPARATOR . $import;

        if (file_exists($baseDeployFilePath)) {
            $importPaths[] = $baseDeployFilePath;
        }

        if (file_exists($projectDeployFilePath)) {
            $importPaths[] = $projectDeployFilePath;
        }

        return $importPaths;
    }
}
