<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Command;

use DeployFileGenerator\DeployFileGeneratorFactory;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Console\Command\Command;
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
        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setInputFilePath($input->getArgument(static::DEPLOY_FILE_PATH));

        $deployFileTransfer = $this->createDeployFileFactory()
            ->createDeployFileConfigProcessor()
            ->process($deployFileTransfer);

        $this->createDeployFileFactory()
            ->createDeployFileOutput()
            ->render($deployFileTransfer);

        return $this->getCommandResult($deployFileTransfer);
    }

    /**
     * @return \DeployFileGenerator\DeployFileGeneratorFactory
     */
    protected function createDeployFileFactory(): DeployFileGeneratorFactory
    {
        return new DeployFileGeneratorFactory();
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return int
     */
    protected function getCommandResult(DeployFileTransfer $deployFileTransfer): int
    {
        if ($deployFileTransfer->getValidationMessageBagTransfer()->getValidationResult() !== []) {
            return Command::FAILURE;
        }

        return Command::SUCCESS;
    }
}
