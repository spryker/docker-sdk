<?php

namespace DeployFileGenerator\Processor;

interface DeployFileProcessorInterface
{
    /**
     * @param string $currentDeployFilePath
     * @param string $outputDeployFilePath
     *
     * @return string
     */
    public function buildDeployFile(string $currentDeployFilePath, string $outputDeployFilePath): string;
}