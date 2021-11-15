<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor;

use DeployFileGenerator\Strategy\DeployFileStrategyInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class DeployFileProcessor implements DeployFileProcessorInterface
{
    /**
     * @var \DeployFileGenerator\Strategy\DeployFileStrategyInterface
     */
    protected $strategy;

    /**
     * @param \DeployFileGenerator\Strategy\DeployFileStrategyInterface $strategy
     */
    public function __construct(DeployFileStrategyInterface $strategy)
    {
        $this->strategy = $strategy;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function process(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        return $this->strategy->execute($deployFileTransfer);
    }
}
