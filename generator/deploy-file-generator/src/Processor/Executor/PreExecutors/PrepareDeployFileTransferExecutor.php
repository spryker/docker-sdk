<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\PreExecutors;

use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\FileFinder\FileFinderInterface;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Yaml\Parser;

class PrepareDeployFileTransferExecutor implements ExecutorInterface
{
    /**
     * @var \Symfony\Component\Yaml\Parser
     */
    protected $yamlParser;

    /**
     * @var \DeployFileGenerator\FileFinder\FileFinderInterface
     */
    protected $fileFinder;

    /**
     * @param \Symfony\Component\Yaml\Parser $yamlParser
     * @param \DeployFileGenerator\FileFinder\FileFinderInterface $fileFinder
     */
    public function __construct(Parser $yamlParser, FileFinderInterface $fileFinder)
    {
        $this->yamlParser = $yamlParser;
        $this->fileFinder = $fileFinder;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $rawData = $this->yamlParser->parseFile($deployFileTransfer->getInputFilePath());
        $imports = $this->getImportsByKeys($rawData);
        $projectImport = $this->getProjectImport($imports);
        $baseImport = $this->getBaseImport($imports);
        $resultData = $this->cleanUpData($rawData);

        $deployFileTransfer = $deployFileTransfer->setRawData($rawData);
        $deployFileTransfer = $deployFileTransfer->setResultData($resultData);
        $deployFileTransfer = $deployFileTransfer->setProjectImports($projectImport);
        $deployFileTransfer = $deployFileTransfer->setBaseImports($baseImport);

        return $deployFileTransfer;

    }

    /**
     * @param array $rawData
     *
     * @return array
     */
    protected function getImportsByKeys(array $rawData): array
    {
        if (!array_key_exists(DeployFileGeneratorConstants::YAML_IMPORTS_KEY, $rawData)) {
            return [];
        }

        return $rawData[DeployFileGeneratorConstants::YAML_IMPORTS_KEY];
    }

    /**
     * @param array $imports
     *
     * @return array
     */
    protected function getProjectImport(array $imports): array
    {
        $result = [];

        foreach ($imports as $importName => $importData) {
            $importData = $importData ?? [];

            if (!array_key_exists(DeployFileGeneratorConstants::YAML_TEMPLATE_KEY, $importData)) {
                $importData[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY] = $importName;
            }

            $filePathOnProjectLayer = $this->fileFinder->getFilePathOnProjectLayer($importData[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY]);
            if ($filePathOnProjectLayer == null) {
                continue;
            }

            $result[$importName . DeployFileGeneratorConstants::YAML_IMPORTS_TEMPLATE_KEY_SEPARATOR . $importData[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY]] = $importData;
        }

        return $result;
    }

    /**
     * @param array $imports
     *
     * @return array
     */
    protected function getBaseImport(array $imports): array
    {
        $result = [];

        foreach ($imports as $importName => $importData) {
            $importData = $importData ?? [];

            if (!array_key_exists(DeployFileGeneratorConstants::YAML_TEMPLATE_KEY, $importData)) {
                $importData[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY] = $importName;
            }

            $filePathOnBaseLayer = $this->fileFinder->getFilePathOnBaseLayer($importData[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY]);
            if ($filePathOnBaseLayer == null) {
                continue;
            }

            $result[$importName . DeployFileGeneratorConstants::YAML_IMPORTS_TEMPLATE_KEY_SEPARATOR . $importData[DeployFileGeneratorConstants::YAML_TEMPLATE_KEY]] = $importData;
        }

        return $result;
    }

    /**
     * @param array $rawData
     *
     * @return array
     */
    protected function cleanUpData(array $rawData): array
    {
        if (!array_key_exists(DeployFileGeneratorConstants::YAML_IMPORTS_KEY, $rawData)) {
            return $rawData;
        }

        unset($rawData[DeployFileGeneratorConstants::YAML_IMPORTS_KEY]);

        return $rawData;
    }
}
