<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator;

use DeployFileGenerator\DeployFileGeneratorConfig;
use DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilder;
use DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilderInterface;
use DeployFileGenerator\Validator\Rule\GroupRegionRule;
use DeployFileGenerator\Validator\Rule\NotEmptyRule;
use DeployFileGenerator\Validator\Rule\OnlyKeyRule;
use DeployFileGenerator\Validator\Rule\OnlyValueRule;
use DeployFileGenerator\Validator\Rule\RangeValueRule;
use DeployFileGenerator\Validator\Rule\RequireRule;
use DeployFileGenerator\Validator\Rule\Type\ArrayTypeRule;
use DeployFileGenerator\Validator\Rule\Type\IntegerTypeRule;
use DeployFileGenerator\Validator\Rule\Type\StringTypeRule;
use Symfony\Component\Yaml\Parser;

class DeployFileValidatorFactory
{
    /**
     * @return \DeployFileGenerator\Validator\DeployFileValidatorInterface
     */
    public function createDeployFileValidator(): DeployFileValidatorInterface
    {
        return new DeployFileValidator(
            $this->createValidationFieldCollectionBuilder(),
        );
    }

    /**
     * @return \DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilderInterface
     */
    protected function createValidationFieldCollectionBuilder(): ValidationFieldCollectionBuilderInterface
    {
        return new ValidationFieldCollectionBuilder(
            $this->createDeployFileConfig()->getValidationRulesFilePath(),
            $this->createSymfonyYamlParser(),
            $this->getValidatorRuleMap(),
        );
    }

    /**
     * @return array<string, string>
     */
    protected function getValidatorRuleMap(): array
    {
        return [
            RequireRule::RULE_NAME => RequireRule::class,
            NotEmptyRule::RULE_NAME => NotEmptyRule::class,
            StringTypeRule::RULE_NAME => StringTypeRule::class,
            OnlyKeyRule::RULE_NAME => OnlyKeyRule::class,
            OnlyValueRule::RULE_NAME => OnlyValueRule::class,
            ArrayTypeRule::RULE_NAME => ArrayTypeRule::class,
            GroupRegionRule::RULE_NAME => GroupRegionRule::class,
            RangeValueRule::RULE_NAME => RangeValueRule::class,
            IntegerTypeRule::RULE_NAME => IntegerTypeRule::class,
        ];
    }

    /**
     * @return \DeployFileGenerator\DeployFileGeneratorConfig
     */
    protected function createDeployFileConfig(): DeployFileGeneratorConfig
    {
        return new DeployFileGeneratorConfig();
    }

    /**
     * @return \Symfony\Component\Yaml\Parser
     */
    public function createSymfonyYamlParser(): Parser
    {
        return new Parser();
    }
}
