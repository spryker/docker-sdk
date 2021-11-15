<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Configurator;

use DeployFileGenerator\Transfer\DeployFileTransfer;

interface DeployFileConfiguratorInterface
{
    /**
     * @param string $inputFilePath
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function config(string $inputFilePath): DeployFileTransfer;
}
