<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use Illuminate\Support\Arr;

class RangeValueRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'range-value';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should be in range %s';

    /**
     * @param string $validateField
     * @param array $data
     *
     * @return bool
     */
    public function isValid(string $validateField, array $data): bool
    {
        if (!$this->isWildCardFieldName($validateField)) {
            if (!Arr::has($data, $validateField)) {
                return true;
            }
        }

        $data = data_get($data, $validateField);

        if ($data == null) {
            return true;
        }

        if (!$this->isWildCardFieldName($validateField) || !is_array($data)) {
            if (!is_int($data)) {
                return true;
            }

            return !($data < $this->ruleConfig[0] || $data > $this->ruleConfig[1]);
        }

        foreach ($data as $range) {
            if (!is_int($range)) {
                continue;
            }

            if ($range > $this->ruleConfig[0] || $range < $this->ruleConfig[1]) {
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
        return sprintf(static::VALIDATION_MESSAGE_TEMPLATE, $fieldName, $this->ruleConfig[0] . '...' . $this->ruleConfig[1]);
    }
}
