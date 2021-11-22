<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Executor;

use DeployFileGenerator\Cleaner\CleanerInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class CleanUpExecutor implements ExecutorInterface
{
    /**
     * @var \DeployFileGenerator\Cleaner\CleanerInterface
     */
    protected $cleaner;

    /**
     * @param \DeployFileGenerator\Cleaner\CleanerInterface $cleaner
     */
    public function __construct(CleanerInterface $cleaner)
    {
        $this->cleaner = $cleaner;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        return $this->cleaner->clean($deployFileTransfer);
    }
}
