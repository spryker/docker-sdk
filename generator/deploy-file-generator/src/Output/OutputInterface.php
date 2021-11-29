<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output;

use DeployFileGenerator\Transfer\DeployFileTransfer;

interface OutputInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return void
     */
    public function render(DeployFileTransfer $deployFileTransfer): void;

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return void
     */
    public function renderDeployFileTransferYaml(DeployFileTransfer $deployFileTransfer): void;

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return void
     */
    public function renderValidationResult(DeployFileTransfer $deployFileTransfer): void;
}
