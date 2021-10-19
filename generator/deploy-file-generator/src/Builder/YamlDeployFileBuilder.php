<?php

namespace DeployFileGenerator\Builder;

use Symfony\Component\Yaml\Dumper;

class YamlDeployFileBuilder implements DeployFileBuilderInterface
{
    /**
     * @var Dumper
     */
    private $dumper;
    /**
     * @var int
     */
    private $inline;

    public function __construct(Dumper $dumper, int $inline = 2)
    {
        $this->dumper = $dumper;
        $this->inline = $inline;
    }

    public function build(array $content, string $outputFilePath): string
    {
        $yamlContent = $this->dumper->dump($content, $this->inline);
        file_put_contents($outputFilePath, $yamlContent);

        return $outputFilePath;
    }
}