<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule\Type;

use DeployFileGenerator\Validator\Rule\AbstractRule;
use Illuminate\Support\Arr;

class StringTypeRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'string-type';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should be String.';

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

        if (!$this->isWildCardFieldName($validateField) || !is_array($data)) {
            return is_string($data);
        }

        foreach ($data as $item) {
            if (!is_string($item) && ($item !== null)) {
                return false;
            }
        }

        return true;
    }
}
