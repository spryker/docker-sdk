<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Command;

use DeployFileGenerator\DeployFileFactory;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\Table;
use Symfony\Component\Console\Helper\TableSeparator;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ConfigCommand extends Command
{
    /**
     * @var string
     */
    protected static $defaultName = 'config';

    /**
     * @var string
     */
    protected const DEPLOY_FILE_PATH = 'deploy-file-path';

    /**
     * @var string
     */
    protected const DEFAULT_DEPLOYMENT_YML_PATH = '/data/deployment/project.yml';

    /**
     * @var string
     */
    protected const COMMAND_DESCRIPTION = 'Deploy yml file path.';

    /**
     * @return void
     */
    protected function configure(): void
    {
        $this->addArgument(
            static::DEPLOY_FILE_PATH,
            InputArgument::OPTIONAL,
            static::COMMAND_DESCRIPTION,
            self::DEFAULT_DEPLOYMENT_YML_PATH,
        );
    }

    /**
     * @param \Symfony\Component\Console\Input\InputInterface $input
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return int
     */
    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $deployFileFactory = $this->createDeployFileFactory();
        $deployFileTransfer = $deployFileFactory->createDeployFileBuilder()->build(
            $input->getArgument(static::DEPLOY_FILE_PATH),
            $input->getArgument(static::DEPLOY_FILE_PATH),
        );

        $data = $deployFileTransfer->getResultData();
        $tables = $this->buildTables($data, $output);

        foreach ($tables as $table) {
            $table->render();
        }

        return Command::SUCCESS;
    }

    /**
     * @param $data
     * @param OutputInterface $output
     *
     * @return array
     */
    protected function buildTables($data, OutputInterface $output): array
    {
        return array_merge(
            [$this->buildMainTable($data, $output)],
            $this->buildTablesBySection($data, $output),
        );
    }

    /**
     * @param $data
     * @param OutputInterface $output
     *
     * @return Table
     */
    protected function buildMainTable($data, OutputInterface $output): Table
    {
        $rows = [];

        foreach ($data as $key => $value) {
            if (!is_array($value)) {
                $rows[] = [$key, $value];
            }
        }

        return $this->createTable('Main configuration:', $rows, $output);
    }

    /**
     * @param array $data
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     *
     * @return array
     */
    protected function buildTablesBySection(array $data, OutputInterface $output): array
    {
        $tables = [];

        foreach ($data as $sectionName => $sectionConfig) {
            if (!is_array($sectionConfig)) {
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

        return $tables;
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
     * @param array $value
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

    /**
     * @return \DeployFileGenerator\DeployFileFactory
     */
    protected function createDeployFileFactory(): DeployFileFactory
    {
        return new DeployFileFactory();
    }
}
