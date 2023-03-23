<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;


class OrRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'or';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should contain one of fields: %s.';

    /**
     * @param string $validateField
     * @param array<string, string> $data
     *
     * @return bool
     */
    public function isValid(string $validateField, array $data): bool
    {
        if (empty($this->ruleConfig)) {
            return true;
        }

        if (!$this->isWildCardFieldName($validateField)) {
            $parentBlock = data_get($data, $validateField);

            return $this->validate($parentBlock);
        }

        $parentBlocks = data_get($data, $validateField);

        foreach ($parentBlocks as $parentBlock) {
            if ($this->validate($parentBlock)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @param array<string, string> $parentBlock
     *
     * @return bool
     */
    private function validate(array $parentBlock): bool
    {
        foreach ($this->ruleConfig as $searchableField) {
            if (array_key_exists($searchableField, $parentBlock)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @param string $fieldName
     *
     * @return string
     */
    public function getValidationMessage(string $fieldName): string
    {
        return sprintf(static::VALIDATION_MESSAGE_TEMPLATE, $fieldName, implode(', ', $this->ruleConfig));
    }
}
