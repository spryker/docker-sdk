<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output;

use DeployFileGenerator\Output\Table\TableBuilderInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Console\Output\OutputInterface as SymfonyOutputInterfaceAlias;

class ValidationTableOutput implements OutputInterface
{
    /**
     * @var \DeployFileGenerator\Output\Table\TableBuilderInterface
     */
    protected $tableBuilder;

    /**
     * @param \DeployFileGenerator\Output\Table\TableBuilderInterface $tableBuilder
     */
    public function __construct(TableBuilderInterface $tableBuilder)
    {
        $this->tableBuilder = $tableBuilder;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return void
     */
    public function render(DeployFileTransfer $deployFileTransfer, SymfonyOutputInterfaceAlias $output): void
    {
        $rows = [];
        $validationResult = $deployFileTransfer->getValidationMessageBagTransfer()->getValidationResult();

        /** @var array<\DeployFileGenerator\Transfer\Validation\Message\ValidationRuleMessageTransfer> $validationMessages */
        foreach ($validationResult as $fieldName => $validationMessages) {
            $validationArray = [];

            foreach ($validationMessages as $validationRuleMessageTransfer) {
                $validationArray[$validationRuleMessageTransfer->getRuleName()] = $validationRuleMessageTransfer->getMessage();
            }

            $rows[] = [$fieldName, $validationArray];
        }

        $this->tableBuilder->buildTable('Validation', $rows, $output)->render();
    }
}
