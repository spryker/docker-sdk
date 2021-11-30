<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\PostExecutors;

use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use DeployFileGenerator\Validator\DeployFileValidatorInterface;

class ValidateDeployFileExecutor implements ExecutorInterface
{
    /**
     * @var \DeployFileGenerator\Validator\DeployFileValidatorInterface
     */
    protected $validator;

    /**
     * @param \DeployFileGenerator\Validator\DeployFileValidatorInterface $validator
     */
    public function __construct(DeployFileValidatorInterface $validator)
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
