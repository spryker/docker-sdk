<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGeneratorTest\Builder;

use Codeception\Test\Unit;
use DeployFileGenerator\Builder\DeployFileBuilder;
use DeployFileGenerator\Builder\DeployFileBuilderInterface;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class DeployFileBuilderTest extends Unit
{
    /**
     * @var string
     */
    protected const INPUT_FILE_PATH = 'input-file-path';
    /**
     * @var string
     */
    protected const OUTPUT_FILE_PATH = 'output-file-path';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testBuild(): void
    {
        $inputFilePath = static::INPUT_FILE_PATH;
        $outputFilePath = static::OUTPUT_FILE_PATH;

        $deployFileTransfer = $this->createDeployFileBuilder()->build($inputFilePath, $outputFilePath);

        $this->tester->assertEquals($outputFilePath, $deployFileTransfer->getOutputFilePath());
    }

    /**
     * @return \DeployFileGenerator\Builder\DeployFileBuilderInterface
     */
    protected function createDeployFileBuilder(): DeployFileBuilderInterface
    {
        return new DeployFileBuilder(
            $this->makeEmpty(DeployFileProcessorInterface::class, [
                'process' => function (DeployFileTransfer $deployFileTransfer) {
                    return $deployFileTransfer;
                },
            ])
        );
    }
}
