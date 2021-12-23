<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor;

use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class DeployFileProcessor implements DeployFileProcessorInterface
{
    /**
     * @var array<\DeployFileGenerator\Processor\Executor\ExecutorInterface>
     */
    protected $executors = [];

    /**
     * @var array<\DeployFileGenerator\Processor\Executor\ExecutorInterface>
     */
    protected $preExecutors = [];

    /**
     * @var array<\DeployFileGenerator\Processor\Executor\ExecutorInterface>
     */
    protected $postExecutors = [];

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function process(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $deployFileTransfer = $this->execute($this->preExecutors, $deployFileTransfer);
        $deployFileTransfer = $this->execute($this->executors, $deployFileTransfer);
        $deployFileTransfer = $this->execute($this->postExecutors, $deployFileTransfer);

        return $deployFileTransfer;
    }

    /**
     * @param \DeployFileGenerator\Processor\Executor\ExecutorInterface $executor
     *
     * @return $this
     */
    public function addPreExecutor(ExecutorInterface $executor)
    {
        $this->preExecutors[] = $executor;

        return $this;
    }

    /**
     * @param \DeployFileGenerator\Processor\Executor\ExecutorInterface $executor
     *
     * @return $this
     */
    public function addExecutor(ExecutorInterface $executor)
    {
        $this->executors[] = $executor;

        return $this;
    }

    /**
     * @param \DeployFileGenerator\Processor\Executor\ExecutorInterface $executor
     *
     * @return $this
     */
    public function addPostExecutor(ExecutorInterface $executor)
    {
        $this->postExecutors[] = $executor;

        return $this;
    }

    /**
     * @param array<\DeployFileGenerator\Processor\Executor\ExecutorInterface> $executors
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    protected function execute(array $executors, DeployFileTransfer $deployFileTransfer)
    {
        foreach ($executors as $executor) {
            $deployFileTransfer = $executor->execute($deployFileTransfer);
        }

        return $deployFileTransfer;
    }
}
