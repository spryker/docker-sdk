<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Transfer\Validation\Field;

use DeployFileGenerator\Transfer\Validation\ValidationRuleCollectionTransfer;

class ValidationFieldTransfer
{
    /**
     * @var string
     */
    protected $fieldName;

    /**
     * @var \DeployFileGenerator\Transfer\Validation\ValidationRuleCollectionTransfer
     */
    protected $rules;

    /**
     * @return string
     */
    public function getFieldName(): string
    {
        return $this->fieldName;
    }

    /**
     * @param string $fieldName
     *
     * @return $this
     */
    public function setFieldName(string $fieldName)
    {
        $this->fieldName = $fieldName;

        return $this;
    }

    /**
     * @return \DeployFileGenerator\Transfer\Validation\ValidationRuleCollectionTransfer
     */
    public function getRules(): ValidationRuleCollectionTransfer
    {
        return $this->rules;
    }

    /**
     * @param \DeployFileGenerator\Transfer\Validation\ValidationRuleCollectionTransfer $rules
     *
     * @return $this
     */
    public function setRules(ValidationRuleCollectionTransfer $rules)
    {
        $this->rules = $rules;

        return $this;
    }
}
