<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output\Table;

use Symfony\Component\Console\Helper\Table;
use Symfony\Component\Console\Helper\TableSeparator;
use Symfony\Component\Console\Output\OutputInterface;

class TableBuilder implements TableBuilderInterface
{
    /**
     * @param string $title
     * @param array $data
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return \Symfony\Component\Console\Helper\Table
     */
    public function buildTable(string $title, array $data, OutputInterface $output): Table
    {
        $title = trim($title, ':') . ':';

        $table = $this->createTable($title, $output);
        $table = $table->setRows($this->buildRowCollection($data));

        return $table;
    }

    /**
     * @param string $title
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return \Symfony\Component\Console\Helper\Table
     */
    protected function createTable(string $title, OutputInterface $output): Table
    {
        $table = new Table($output->section());

        $table = $table->setColumnWidth(0, 30);
        $table = $table->setColumnWidth(1, 100);
        $table = $table->setHeaderTitle($title);

        return $table;
    }

    /**
     * @param array $rows
     *
     * @return array
     */
    protected function buildRowCollection(array $rows): array
    {
        $rowsWithSeparator = [];

        foreach ($rows as $row) {
            if (is_array($row[1])) {
                $row[1] = $this->generateArrayRow($row[1]);
            }

            $rowsWithSeparator[] = $row;
            $rowsWithSeparator[] = new TableSeparator();
        }

        array_pop($rowsWithSeparator);

        return $rowsWithSeparator;
    }

    /**
     * @param array $value
     * @param int $deep
     *
     * @return string
     */
    protected function generateArrayRow(array $value, int $deep = 0): string
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

            $result .= $tabs . $key . ' : ' . PHP_EOL . $this->generateArrayRow($item, $deep + 1) . PHP_EOL;
        }

        return rtrim($result);
    }
}
