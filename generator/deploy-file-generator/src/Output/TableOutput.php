<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output;

use DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer;
use Symfony\Component\Console\Helper\Table;
use Symfony\Component\Console\Helper\TableSeparator;
use Symfony\Component\Console\Output\OutputInterface;

class TableOutput implements TableOutputInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer $validationMessageBagTransfer
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return void
     */
    public function buildValidationResult(ValidationMessageBagTransfer $validationMessageBagTransfer, OutputInterface $output): void
    {
        $validationResult = $validationMessageBagTransfer->getValidationResult();
        $rows = [];

        /** @var array<ValidationRuleMessageTransfer> $validationMessages */
        foreach ($validationResult as $fieldName => $validationMessages) {
            $validationArray = [];

            foreach ($validationMessages as $validationRuleMessageTransfer) {
                $validationArray[$validationRuleMessageTransfer->getRuleName()] = $validationRuleMessageTransfer->getMessage();
            }

            $rows[] = [$fieldName, $this->generateRow($validationArray)];
        }

        $this->createTable('Validation:', $rows, $output)->render();
    }

    /**
     * @param array $data
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return void
     */
    public function buildConfig(array $data, OutputInterface $output): void
    {
        $tables = [];
        $mainTableRows = [];

        foreach ($data as $sectionName => $sectionConfig) {
            if (!is_array($sectionConfig)) {
                $mainTableRows[] = [$sectionName, $sectionConfig];

                continue;
            }

            $rows = [];

            foreach ($sectionConfig as $key => $item) {
                if (!is_array($item)) {
                    $rows[] = [$key, $item];

                    continue;
                }

                $rows[] = [$key, $this->generateRow($item)];
            }

            $tables[] = $this->createTable($sectionName, $rows, $output);
        }

        $tables[] = $this->createTable('Main configuration:', $mainTableRows, $output);

        foreach ($tables as $table) {
            $table->render();
        }
    }

    /**
     * @param string $title
     * @param array $rows
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return \Symfony\Component\Console\Helper\Table
     */
    protected function createTable(string $title, array $rows, OutputInterface $output): Table
    {
        $table = new Table($output->section());

        $table = $table->setColumnWidth(0, 30);
        $table = $table->setColumnWidth(1, 100);
        $table = $table->setHeaderTitle($title);

        $rowCount = count($rows);

        if ($rowCount <= 1) {
            $table = $table->setRows($rows);

            return $table;
        }

        $separatorCount = count($rows) - 1;

        $rowsWithSeparator = [];

        foreach ($rows as $row) {
            $rowsWithSeparator[] = $row;

            if ($separatorCount > 0) {
                $rowsWithSeparator[] = new TableSeparator();
                $separatorCount -= 1;
            }
        }

        $table = $table->setRows($rowsWithSeparator);

        return $table;
    }

    /**
     * @param array $valueSymfonyOutputInterface
     * @param int $deep
     *
     * @return string
     */
    protected function generateRow(array $value, int $deep = 0): string
    {
        $tabs = str_repeat('  ', $deep);
        $result = '';

        foreach ($value as $key => $item) {
            if (!is_array($item)) {
                if (is_bool($item)) {
                    $item = $item ? 'true' : 'false';
                }

                $keyWithSeparator = is_int($key) ? ' * ' : $key . ' : ';

                $result .= $tabs . $keyWithSeparator . $item . ';' . PHP_EOL;

                continue;
            }

            $result .= $tabs . $key . ' : ' . PHP_EOL . $this->generateRow($item, $deep + 1) . PHP_EOL;
        }

        return rtrim($result);
    }
}
