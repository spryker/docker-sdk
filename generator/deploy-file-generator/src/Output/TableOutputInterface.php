<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output;

use DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer;
use Symfony\Component\Console\Output\OutputInterface as SymfonyOutputInterface;

interface TableOutputInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer $validationMessageBagTransfer
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return void
     */
    public function buildValidationResult(ValidationMessageBagTransfer $validationMessageBagTransfer, SymfonyOutputInterface $output): void;

    /**
     * @param array $data
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return void
     */
    public function buildConfig(array $data, SymfonyOutputInterface $output): void;
}
