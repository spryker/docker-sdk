<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor;

use DeployFileGenerator\Transfer\DeployFileTransfer;

class DeployFileProcessor implements DeployFileProcessorInterface
{
    /**
     * @var array<\DeployFileGenerator\Executor\ExecutorInterface>
     */
    protected $executors;

    /**
     * @param array<\DeployFileGenerator\Executor\ExecutorInterface> $executors
     */
    public function __construct(array $executors)
    {
        $this->executors = $executors;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function process(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        foreach ($this->executors as $executor) {
            $deployFileTransfer = $executor->execute($deployFileTransfer);
        }

        return $deployFileTransfer;
    }
}
