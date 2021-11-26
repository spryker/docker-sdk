<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use Illuminate\Support\Arr;

class OnlyValueRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'only-value';

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

        if (!$this->isWildCardFieldName($validateField) && !is_array($data)) {
            return in_array($data, $this->ruleConfig);
        }

        if ($data == null) {
            return true;
        }

        $data = array_filter($data);

        foreach ($data as $value) {
            if (is_array($value)) {
                $value = Arr::first($value);
            }

            if (!in_array($value, $this->ruleConfig)) {
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
