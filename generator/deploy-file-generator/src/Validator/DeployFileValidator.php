<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator;

use DeployFileGenerator\Transfer\DeployFileTransfer;
use DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer;
use DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer;
use DeployFileGenerator\Transfer\Validation\Message\ValidationRuleMessageTransfer;
use DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilderInterface;

class DeployFileValidator implements DeployFileValidatorInterface
{
    /**
     * @var \DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilderInterface
     */
    protected $validationFieldCollectionBuilder;

    /**
     * @param \DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilderInterface $validationFieldCollectionBuilder
     */
    public function __construct(ValidationFieldCollectionBuilderInterface $validationFieldCollectionBuilder)
    {
        $this->validationFieldCollectionBuilder = $validationFieldCollectionBuilder;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function validate(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $validationMessageBagTransfer = new ValidationMessageBagTransfer();

        $deployFileResultData = $deployFileTransfer->getResultData();
        $validationFieldCollectionTransfer = $this->validationFieldCollectionBuilder->buildValidationFieldCollection();

        foreach ($validationFieldCollectionTransfer->getFields() as $validationFieldTransfer) {
            $validationMessageBagTransfer = $this->validateField($validationFieldTransfer, $deployFileResultData, $validationMessageBagTransfer);
        }

        $deployFileTransfer = $deployFileTransfer->setValidationMessageBagTransfer($validationMessageBagTransfer);

        return $deployFileTransfer;
    }

    /**
     * @param \DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer $validationFieldTransfer
     * @param array $deployFileResultData
     * @param \DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer $validationMessageBagTransfer
     *
     * @return \DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer
     */
    protected function validateField(
        ValidationFieldTransfer $validationFieldTransfer,
        array $deployFileResultData,
        ValidationMessageBagTransfer $validationMessageBagTransfer
    ): ValidationMessageBagTransfer {
        $fieldName = $validationFieldTransfer->getFieldName();
        $validationRuleCollection = $validationFieldTransfer->getRules()->getValidationRules();

        foreach ($validationRuleCollection as $validationRule) {
            if ($validationRule->isValid($fieldName, $deployFileResultData)) {
                continue;
            }

            $validationRuleMessageTransfer = new ValidationRuleMessageTransfer();
            $validationRuleMessageTransfer = $validationRuleMessageTransfer->setRuleName($validationRule->getRuleName());
            $validationRuleMessageTransfer = $validationRuleMessageTransfer->setMessage($validationRule->getValidationMessage($fieldName));

            $validationMessageBagTransfer = $validationMessageBagTransfer->addValidationResult($fieldName, $validationRuleMessageTransfer);
        }

        return $validationMessageBagTransfer;
    }
}
