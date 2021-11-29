<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Transfer\Validation\Message;

class ValidationMessageBagTransfer
{
    /**
     * @var array<string, array>
     */
    protected $validationResult = [];

    /**
     * @return array<string, array>
     */
    public function getValidationResult(): array
    {
        return $this->validationResult;
    }

    /**
     * @param array<string, array> $validationResult
     *
     * @return $this
     */
    public function setValidationResult(array $validationResult)
    {
        $this->validationResult = $validationResult;

        return $this;
    }

    /**
     * @param string $fieldName
     * @param \DeployFileGenerator\Transfer\Validation\Message\ValidationRuleMessageTransfer $validationRuleMessageTransfer
     *
     * @return $this
     */
    public function addValidationResult(string $fieldName, ValidationRuleMessageTransfer $validationRuleMessageTransfer)
    {
        $this->validationResult[$fieldName][] = $validationRuleMessageTransfer;

        return $this;
    }
}
