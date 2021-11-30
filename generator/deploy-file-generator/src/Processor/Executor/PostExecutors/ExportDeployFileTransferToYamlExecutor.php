<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\PostExecutors;

use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Yaml\Dumper;

class ExportDeployFileTransferToYamlExecutor implements ExecutorInterface
{
    /**
     * @var \Symfony\Component\Yaml\Dumper
     */
    protected $dumper;

    /**
     * @var int
     */
    protected $inline;

    /**
     * @param \Symfony\Component\Yaml\Dumper $dumper
     * @param int $inline
     */
    public function __construct(Dumper $dumper, int $inline = 0)
    {
        $this->dumper = $dumper;
        $this->inline = $inline;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $yamlContent = $this->dumper->dump($deployFileTransfer->getResultData(), $this->inline);
        file_put_contents($deployFileTransfer->getOutputFilePath(), $yamlContent);

        return $deployFileTransfer;
    }
}
