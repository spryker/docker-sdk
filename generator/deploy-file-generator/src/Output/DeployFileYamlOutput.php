<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Output;

use DeployFileGenerator\Transfer\DeployFileTransfer;
use Symfony\Component\Console\Output\OutputInterface as SymfonyOutputInterface;
use Symfony\Component\Yaml\Dumper;

class DeployFileYamlOutput implements OutputInterface
{
    /**
     * @var \Symfony\Component\Yaml\Dumper
     */
    protected $dumper;

    /**
     * @var int
     */
    protected $yamlInline;

    /**
     * @param \Symfony\Component\Yaml\Dumper $dumper
     * @param int $yamlInline
     */
    public function __construct(Dumper $dumper, int $yamlInline = 0)
    {
        $this->dumper = $dumper;
        $this->yamlInline = $yamlInline;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     * @param \DeployFileGenerator\Output\OutputInterface $output
     *
     * @return void
     */
    public function render(DeployFileTransfer $deployFileTransfer, SymfonyOutputInterface $output): void
    {
        $output->writeln(
            $this->dumper->dump(
                $deployFileTransfer->getResultData(),
                $this->yamlInline,
            ),
        );
    }
}
