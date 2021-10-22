<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Builder;

use DeployFileGenerator\Processor\DeployFileProcessor;
use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class DeployFileBuilder implements DeployFileBuilderInterface
{
    /**
     * @var \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    protected $deployFileBuildProcessor;

    /**
     * @param \DeployFileGenerator\Processor\DeployFileProcessorInterface $deployFileBuildProcessor
     */
    public function __construct(DeployFileProcessorInterface $deployFileBuildProcessor)
    {
        $this->deployFileBuildProcessor = $deployFileBuildProcessor;
    }

    /**
     * @param string $inputFilePath
     * @param string $outputFilePath
     *
     * @return string
     */
    public function build(string $inputFilePath, string $outputFilePath): string
    {
        $deployFileTransfer = new DeployFileTransfer();

        $deployFileTransfer = $deployFileTransfer->setInputFilePath($inputFilePath);
        $deployFileTransfer = $deployFileTransfer->setOutputFilePath($outputFilePath);

        $deployFileTransfer = $this->deployFileBuildProcessor->process($deployFileTransfer);

        return $deployFileTransfer->getOutputFilePath();
    }
}
