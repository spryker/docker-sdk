<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Importer;

use Codeception\Test\Unit;
use DeployFileGenerator\Importer\DataImporter;
use DeployFileGenerator\Importer\DeployFileImporterInterface;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;
use DeployFileGenerator\ParametersResolver\ParametersResolverInterface;
use Symfony\Component\Yaml\Parser;

class YamlDataImporterTest extends Unit
{
    /**
     * @var string
     */
    protected const PATH_PREFIX = './deploy-file-generator/tests/_data/templates/yml-data-importer-test/';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testImportFromFile(): void
    {
        // Arrange
        $expectedResult = [
            'imported-key' => 'imported data',
            'some-key' => 'some data',
            'imports' => [],
        ];

        // Act
        $data = $this->createYamlDataImporter()->importFromFile(static::PATH_PREFIX . 'data.yml');

        // Assert
        $this->tester->assertEquals($expectedResult, $data);
    }

    /**
     * @return \DeployFileGenerator\Importer\DeployFileImporterInterface
     */
    protected function createYamlDataImporter(): DeployFileImporterInterface
    {
        return new DataImporter(
            static::PATH_PREFIX,
            $this->make(Parser::class),
            $this->makeEmpty(ParametersResolverInterface::class, [
                'resolveParams' => function (array $content, array $params = []) {
                    return $content;
                },
            ]),
            $this->makeEmpty(MergeResolverInterface::class, [
                'resolve' => function (array $projectData, array $importData) {
                    return array_merge_recursive($importData, $projectData);
                },
            ]),
        );
    }
}
