<?php

namespace DeployFileGenerator\Loader;

use DeployFileGenerator\ParameterResolver\ParametersResolver;
use DeployFileGenerator\DeployFileConfig;
use Symfony\Component\Yaml\Parser;

class YamlDeployFileLoader implements DeployFileLoaderInterface
{
    /**
     * @var Parser
     */
    private $parser;
    /**
     * @var ParametersResolver
     */
    private $parametersResolver;
    /**
     * @var DeployFileConfig
     */
    private $config;

    /**
     * @param Parser $parser
     * @param ParametersResolver $parametersResolver
     * @param DeployFileConfig $config
     */
    public function __construct(
        Parser             $parser,
        ParametersResolver $parametersResolver,
        DeployFileConfig   $config
    ){
        $this->parser = $parser;
        $this->parametersResolver = $parametersResolver;
        $this->config = $config;
    }

    /**
     * @param string $resource
     * @param array $parameters
     *
     * @return array
     */
    public function load(string $resource, array $parameters = []): array
    {
        $content = $this->parser->parseFile($resource);
        $content = $this->parametersResolver->resolveParams($content, $parameters);

        return $this->parseImports($content, $parameters);
    }


    /**
     * @param array $content
     * @param array $parentParameters
     *
     * @return array
     */
    private function parseImports(array $content, array $parentParameters = []): array
    {
        /*todo: merger + conflict resolver*/
        if (!array_key_exists('imports', $content)) {
            return $content;
        }

        foreach ($content['imports'] as $importPath => $importOptions) {
            $importOptions = $importOptions['parameters'] ?? [];
            $importOptions = array_merge($parentParameters, $importOptions);

            foreach ($this->getImportFilePaths($importPath) as $importFilePath) {
                $data = $this->load($importFilePath, $importOptions);
                $content = array_merge($content, $data);
            }
        }

        unset($content['imports']);

        return $content;
    }

    /**
     * @param string $import
     *
     * @return string[]
     */
    private function getImportFilePaths(string $import): array
    {
        $importPaths = [];

        $importPaths[] = $this->config->getBaseDirectoryPath() . $import;
        $importPaths[] = $this->config->getProjectDirectoryPath() . $import;

        return array_filter($importPaths, function ($filePath) {
            return file_exists($filePath);
        });
    }
}
