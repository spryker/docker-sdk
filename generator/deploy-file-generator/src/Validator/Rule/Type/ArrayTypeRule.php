<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule\Type;

use DeployFileGenerator\Validator\Rule\AbstractRule;
use Illuminate\Support\Arr;

class ArrayTypeRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'array-type';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should be Array.';

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

        if ($data == null) {
            return true;
        }

        if (!$this->isWildCardFieldName($validateField)) {
            return is_array($data);
        }

        foreach ($data as $item) {
            if ($item == null) {
                continue;
            }

            if (!is_array($item)) {
                return false;
            }
        }

        return true;
    }
}
