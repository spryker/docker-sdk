<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Builder;

use DeployFileGenerator\Transfer\Validation\Field\ValidationFieldCollectionTransfer;
use DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer;
use DeployFileGenerator\Transfer\Validation\ValidationRuleCollectionTransfer;
use DeployFileGenerator\Validator\Rule\RuleInterface;
use RuntimeException;
use Symfony\Component\Yaml\Parser;

class ValidationFieldCollectionBuilder implements ValidationFieldCollectionBuilderInterface
{
    /**
     * @var string
     */
    protected $validationRulesConfigFilePath;

    /**
     * @var \Symfony\Component\Yaml\Parser
     */
    protected $yamlParser;

    /**
     * @var array<string, string>
     */
    protected $validatorRuleMap;

    /**
     * @param string $validationRulesConfigFilePath
     * @param \Symfony\Component\Yaml\Parser $yamlParser
     * @param array<string, string> $validatorRuleMap
     */
    public function __construct(
        string $validationRulesConfigFilePath,
        Parser $yamlParser,
        array $validatorRuleMap
    ) {
        $this->validationRulesConfigFilePath = $validationRulesConfigFilePath;
        $this->yamlParser = $yamlParser;
        $this->validatorRuleMap = $validatorRuleMap;
    }

    /**
     * @return \DeployFileGenerator\Transfer\Validation\Field\ValidationFieldCollectionTransfer
     */
    public function buildValidationFieldCollection(): ValidationFieldCollectionTransfer
    {
        $validationFieldCollectionTransfer = new ValidationFieldCollectionTransfer();
        $deployFileValidationRulesFromConfig = $this->yamlParser
            ->parseFile($this->validationRulesConfigFilePath);

        foreach ($deployFileValidationRulesFromConfig as $fieldName => $validationRules) {
            if (empty($validationRules)) {
                continue;
            }

            $validationFieldTransfer = $this->createValidationFieldTransfer($fieldName, $validationRules);
            $validationFieldCollectionTransfer = $validationFieldCollectionTransfer->addField($validationFieldTransfer);
        }

        return $validationFieldCollectionTransfer;
    }

    /**
     * @param string $fieldName
     * @param array $validationRules
     *
     * @return \DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer
     */
    protected function createValidationFieldTransfer(string $fieldName, array $validationRules): ValidationFieldTransfer
    {
        $validationRuleCollectionTransfer = new ValidationRuleCollectionTransfer();

        foreach ($validationRules as $validationRuleName => $validationRuleConfig) {
            $validationRule = $this->createValidationRuleByName($validationRuleName, $validationRuleConfig ?? []);
            $validationRuleCollectionTransfer = $validationRuleCollectionTransfer->addRule($validationRule);
        }

        $validationFieldTransfer = new ValidationFieldTransfer();
        $validationFieldTransfer = $validationFieldTransfer->setFieldName($fieldName);
        $validationFieldTransfer = $validationFieldTransfer->setRules($validationRuleCollectionTransfer);

        return $validationFieldTransfer;
    }

    /**
     * @param string $validationRuleName
     * @param array $validationRuleConfig
     *
     * @throws \RuntimeException
     *
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    protected function createValidationRuleByName(string $validationRuleName, array $validationRuleConfig = []): RuleInterface
    {
        if (!array_key_exists($validationRuleName, $this->validatorRuleMap)) {
            throw new RuntimeException(sprintf('`%s` rule does not registration.', $validationRuleName));
        }

        return new $this->validatorRuleMap[$validationRuleName]($validationRuleConfig);
    }
}
