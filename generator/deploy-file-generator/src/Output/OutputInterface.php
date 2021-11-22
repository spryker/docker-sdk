<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output;

use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Console\Output\OutputInterface as SymfonyOutputInterface;

interface OutputInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return void
     */
    public function render(DeployFileTransfer $deployFileTransfer, SymfonyOutputInterface $output): void;
}
