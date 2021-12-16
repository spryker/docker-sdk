<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use Illuminate\Support\Arr;

class OnlyKeyRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'only-key';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should contain %s only.';

    /**
     * @param string $validateField
     * @param array $data
     *
     * @return bool
     */
    public function isValid(string $validateField, array $data): bool
    {
        if (!$this->isWildCardFieldName($validateField) && !Arr::has($data, $validateField)) {
            return true;
        }

        $data = data_get($data, $validateField);

        if (!$this->isWildCardFieldName($validateField)) {
            return array_diff(array_keys($data), $this->ruleConfig) == [];
        }

        foreach ($data as $value) {
            if (array_diff(array_keys($value), $this->ruleConfig) !== []) {
                return false;
            }
        }

        return true;
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
