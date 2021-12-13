<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output;

use DeployFileGenerator\DeployFileGeneratorConfig;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Console\Output\OutputInterface as SymfonyOutputInterface;
use Symfony\Component\Yaml\Dumper;

class DeployFileOutput implements OutputInterface
{
    /**
     * @var string
     */
    protected const VALIDATION_OUTPUT_TITLE = '*** Validation Result: ***';

    /**
     * @var string
     */
    protected const VALIDATION_OUTPUT_END = '******';

    /**
     * @var string
     */
    protected const VALIDATION_OUTPUT_MESSAGE_TEMPLATE = '%d) %s' . PHP_EOL;

    /**
     * @var string
     */
    protected const VALIDATION_OUTPUT_MESSAGE_SEPARATOR = '---';

    /**
     * @var \Symfony\Component\Yaml\Dumper
     */
    protected $dumper;

    /**
     * @var \DeployFileGenerator\DeployFileGeneratorConfig
     */
    protected $config;

    /**
     * @var \Symfony\Component\Console\Output\OutputInterface
     */
    protected $output;

    /**
     * @param \Symfony\Component\Console\Output\OutputInterface $output
     * @param \Symfony\Component\Yaml\Dumper $dumper
     * @param \DeployFileGenerator\DeployFileGeneratorConfig $config
     */
    public function __construct(SymfonyOutputInterface $output, Dumper $dumper, DeployFileGeneratorConfig $config)
    {
        $this->dumper = $dumper;
        $this->config = $config;
        $this->output = $output;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return void
     */
    public function render(DeployFileTransfer $deployFileTransfer): void
    {
        $this->renderDeployFileTransferYaml($deployFileTransfer);
        $this->renderValidationResult($deployFileTransfer);
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return void
     */
    public function renderDeployFileTransferYaml(DeployFileTransfer $deployFileTransfer): void
    {
        $this->output->writeln(
            $this->dumper->dump(
                $deployFileTransfer->getResultData(),
                $this->config->getYamlInline(),
            ),
        );
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return void
     */
    public function renderValidationResult(DeployFileTransfer $deployFileTransfer): void
    {
        $validationResult = $deployFileTransfer->getValidationMessageBagTransfer()->getValidationResult();

        if ($validationResult !== []) {
            $this->output->writeln([self::VALIDATION_OUTPUT_TITLE, '']);

            $counter = 1;
            foreach ($validationResult as $validationRuleMessageTransferCollection) {
                /** @var \DeployFileGenerator\Transfer\Validation\Message\ValidationRuleMessageTransfer $validationRuleMessageTransfer */
                foreach ($validationRuleMessageTransferCollection as $validationRuleMessageTransfer) {
                    $this->output->writeln(
                        [
                            sprintf(static::VALIDATION_OUTPUT_MESSAGE_TEMPLATE, $counter, $validationRuleMessageTransfer->getMessage()),
                            self::VALIDATION_OUTPUT_MESSAGE_SEPARATOR,
                        ],
                    );

                    $counter++;
                }
            }

            $this->output->writeln(self::VALIDATION_OUTPUT_END);
        }
    }
}
