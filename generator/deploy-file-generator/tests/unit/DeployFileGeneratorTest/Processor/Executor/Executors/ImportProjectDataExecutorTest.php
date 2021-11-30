<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Processor\Executor\Executors;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorConstants;
use DeployFileGenerator\Importer\DeployFileImporterInterface;
use DeployFileGenerator\MergeResolver\MergeResolverInterface;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Processor\Executor\Executors\ImportProjectDataExecutor;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class ImportProjectDataExecutorTest extends Unit
{
    /**
     * @var string
     */
    protected const IMPORTED_FILES_KEY = 'imported-files';

    /**
     * @var string
     */
    protected const IMPORT_DATA_YML_PATH = 'import-data.yml';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testExecute(): void
    {
        // Arrange
        $deployFileTransfer = $this->createDeployFileTransfer();

        // Act
        $deployFileTransfer = $this->createImportProjectDataExecutor()
            ->execute($deployFileTransfer);

        // Assert
        $this->tester->assertEquals([
            'some-key' => 'some data',
            DeployFileGeneratorConstants::YAML_IMPORTS_KEY => [
                static::IMPORT_DATA_YML_PATH => null,
            ],
            static::IMPORTED_FILES_KEY => [
                static::IMPORT_DATA_YML_PATH,
            ],
        ], $deployFileTransfer->getResultData());
    }

    /**
     * @return \DeployFileGenerator\Processor\Executor\ExecutorInterface
     */
    protected function createImportProjectDataExecutor(): ExecutorInterface
    {
        return new ImportProjectDataExecutor(
            $this->makeEmpty(DeployFileImporterInterface::class, [
                'importFromData' => function (array $data, array $parameters = []) {
                    if (!array_key_exists(DeployFileGeneratorConstants::YAML_IMPORTS_KEY, $data)) {
                        return $data;
                    }
                    $data[static::IMPORTED_FILES_KEY] = array_keys($data[DeployFileGeneratorConstants::YAML_IMPORTS_KEY]);

                    return $data;
                },
            ]),
            $this->makeEmpty(MergeResolverInterface::class),
        );
    }

    /**
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    protected function createDeployFileTransfer(): DeployFileTransfer
    {
        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setProjectImports([
            self::IMPORT_DATA_YML_PATH => null,
        ]);
        $deployFileTransfer = $deployFileTransfer->setResultData([
            'some-key' => 'some data',
        ]);

        return $deployFileTransfer;
    }
}
