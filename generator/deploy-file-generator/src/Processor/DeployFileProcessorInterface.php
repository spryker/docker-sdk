<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor;

use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

interface DeployFileProcessorInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function process(DeployFileTransfer $deployFileTransfer): DeployFileTransfer;

    /**
     * @param \DeployFileGenerator\Processor\Executor\ExecutorInterface $executor
     *
     * @return $this
     */
    public function addPreExecutor(ExecutorInterface $executor);

    /**
     * @param \DeployFileGenerator\Processor\Executor\ExecutorInterface $executor
     *
     * @return $this
     */
    public function addExecutor(ExecutorInterface $executor);

    /**
     * @param \DeployFileGenerator\Processor\Executor\ExecutorInterface $executor
     *
     * @return $this
     */
    public function addPostExecutor(ExecutorInterface $executor);
}
