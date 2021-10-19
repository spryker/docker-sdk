<?php

namespace DeployFileGenerator\Builder;

interface DeployFileBuilderInterface
{
    /**
     * @param array $content
     * @param string $outputFilePath
     *
     * @return string
     */
    public function build(array $content, string $outputFilePath): string;
}