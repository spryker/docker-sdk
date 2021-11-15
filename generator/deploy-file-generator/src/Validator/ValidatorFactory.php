<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator;

use DeployFileGenerator\ArrayAccessor\ArrayAccessor;
use DeployFileGenerator\ArrayAccessor\ArrayAccessorInterface;
use DeployFileGenerator\DeployFileFactory;
use DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilder;
use DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilderInterface;
use DeployFileGenerator\Validator\Rule\GroupRegionRule;
use DeployFileGenerator\Validator\Rule\NotEmptyRule;
use DeployFileGenerator\Validator\Rule\OnlyKeyRule;
use DeployFileGenerator\Validator\Rule\OnlyValueRule;
use DeployFileGenerator\Validator\Rule\RangeValue;
use DeployFileGenerator\Validator\Rule\RequireRule;
use DeployFileGenerator\Validator\Rule\Type\ArrayType;
use DeployFileGenerator\Validator\Rule\Type\StringTypeRule;

class ValidatorFactory
{
    /**
     * @return \DeployFileGenerator\Validator\ValidatorInterface
     */
    public function createValidator(): ValidatorInterface
    {
        return new Validator(
            $this->createValidationFieldCollectionBuilder(),
        );
    }

    /**
     * @return \DeployFileGenerator\ArrayAccessor\ArrayAccessorInterface
     */
    protected function createArrayAccessor(): ArrayAccessorInterface
    {
        return new ArrayAccessor();
    }

    /**
     * @return \DeployFileGenerator\Validator\Builder\ValidationFieldCollectionBuilderInterface
     */
    protected function createValidationFieldCollectionBuilder(): ValidationFieldCollectionBuilderInterface
    {
        return new ValidationFieldCollectionBuilder(
            $this->createDeployFileFactory()->createDeployFileConfig()->getValidationRulesFilePath(),
            $this->createDeployFileFactory()->createSymfonyYamlParser(),
            $this->getValidatorRuleMap(),
        );
    }

    /**
     * @return \DeployFileGenerator\DeployFileFactory
     */
    protected function createDeployFileFactory(): DeployFileFactory
    {
        return new DeployFileFactory();
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
            ArrayType::RULE_NAME => ArrayType::class,
            GroupRegionRule::RULE_NAME => GroupRegionRule::class,
            RangeValue::RULE_NAME => RangeValue::class,
        ];
    }
}
