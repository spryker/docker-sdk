<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Importer;

use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;
use DeployFileGenerator\ParametersResolver\ParametersResolverInterface;
use Symfony\Component\Yaml\Parser;

class DataImporter implements DeployFileImporterInterface
{
    /**
     * @var \Symfony\Component\Yaml\Parser
     */
    protected $parser;

    /**
     * @var \DeployFileGenerator\ParametersResolver\ParametersResolverInterface
     */
    protected $parametersResolver;

    /**
     * @var \DeployFileGenerator\MergeResolver\MergeResolverInterface
     */
    protected $mergeResolver;

    /**
     * @var string
     */
    protected $pathPrefix;

    /**
     * @param string $pathPrefix
     * @param \Symfony\Component\Yaml\Parser $parser
     * @param \DeployFileGenerator\ParametersResolver\ParametersResolverInterface $parametersResolver
     * @param \DeployFileGenerator\MergeResolver\MergeResolverInterface $mergeResolver
     */
    public function __construct(
        string $pathPrefix,
        Parser $parser,
        ParametersResolverInterface $parametersResolver,
        MergeResolverInterface $mergeResolver
    ) {
        $this->pathPrefix = $pathPrefix;
        $this->parser = $parser;
        $this->parametersResolver = $parametersResolver;
        $this->mergeResolver = $mergeResolver;
    }

    /**
     * @param array $data
     * @param array $parameters
     *
     * @return array
     */
    public function importFromData(array $data, array $parameters = []): array
    {
        $data = $this->parametersResolver->resolveParams($data, $parameters);
        $data = $this->parseImports($data, $parameters);

        return $data;
    }

    /**
     * @param string $filePath
     * @param array $parameters
     *
     * @return array
     */
    public function importFromFile(string $filePath, array $parameters = []): array
    {
        $data = $this->parser->parseFile($filePath);

        return $this->importFromData($data, $parameters);
    }

    /**
     * @param array $content
     * @param array $parentParameters
     *
     * @return array
     */
    protected function parseImports(array $content, array $parentParameters = []): array
    {
        if (!array_key_exists(DeployFileGeneratorConstants::YAML_IMPORTS_KEY, $content)) {
            return $content;
        }

        foreach ($content[DeployFileGeneratorConstants::YAML_IMPORTS_KEY] as $importName => $importParams) {
            if (strpos($importName, DeployFileGeneratorConstants::YAML_IMPORTS_TEMPLATE_KEY_SEPARATOR) !== false) {
                $importName = explode(DeployFileGeneratorConstants::YAML_IMPORTS_TEMPLATE_KEY_SEPARATOR, $importName)[1];
            }

            $importName = $importParams[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY] ?? $importName;
            $importParams = $importParams[DeployFileGeneratorConstants::YAML_PARAMETERS_KEY] ?? [];
            $importParams = array_merge($parentParameters, $importParams);

            $importedData = $this->importFromFile($this->getImportFilePath((string)$importName, $importParams), $importParams);

            $content = $this->mergeResolver->resolve($content, $importedData);

            unset($content[DeployFileGeneratorConstants::YAML_IMPORTS_KEY][$importName]);
        }

        return $content;
    }

    /**
     * @param string $importName
     * @param array $importParams
     *
     * @return string
     */
    protected function getImportFilePath(string $importName, array $importParams): string
    {
        $importPath = $importParams[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY] ?? $importName;

        if (strpos($importName, DeployFileGeneratorConstants::YAML_IMPORTS_TEMPLATE_KEY_SEPARATOR) !== false) {
            $importPath = explode(DeployFileGeneratorConstants::YAML_IMPORTS_TEMPLATE_KEY_SEPARATOR, $importName)[1];
        }

        return $this->pathPrefix . $importPath;
    }
}
