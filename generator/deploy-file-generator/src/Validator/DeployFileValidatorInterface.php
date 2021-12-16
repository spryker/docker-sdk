<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator;

use DeployFileGenerator\Transfer\DeployFileTransfer;

interface DeployFileValidatorInterface
{
    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function validate(DeployFileTransfer $deployFileTransfer): DeployFileTransfer;
}
