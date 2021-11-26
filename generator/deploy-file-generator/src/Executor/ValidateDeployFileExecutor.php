<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Executor;

use DeployFileGenerator\Transfer\DeployFileTransfer;
use DeployFileGenerator\Validator\ValidatorInterface;

class ValidateDeployFileExecutor implements ExecutorInterface
{
    /**
     * @var \DeployFileGenerator\Validator\ValidatorInterface
     */
    protected $validator;

    /**
     * @param \DeployFileGenerator\Validator\ValidatorInterface $validator
     */
    public function __construct(ValidatorInterface $validator)
    {
        $this->validator = $validator;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        return $this->validator->validate($deployFileTransfer);
    }
}
