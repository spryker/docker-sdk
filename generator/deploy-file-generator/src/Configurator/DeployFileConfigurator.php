<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Configurator;

use DeployFileGenerator\Processor\DeployFileProcessorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class DeployFileConfigurator implements DeployFileConfiguratorInterface
{
    /**
     * @var \DeployFileGenerator\Processor\DeployFileProcessorInterface
     */
    protected $deployFileConfigProcessor;

    /**
     * @param \DeployFileGenerator\Processor\DeployFileProcessorInterface $deployFileConfigProcessor
     */
    public function __construct(DeployFileProcessorInterface $deployFileConfigProcessor)
    {
        $this->deployFileConfigProcessor = $deployFileConfigProcessor;
    }

    /**
     * @param string $inputFilePath
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function config(string $inputFilePath): DeployFileTransfer
    {
        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setInputFilePath($inputFilePath);

        return $this->deployFileConfigProcessor->process($deployFileTransfer);
    }
}
