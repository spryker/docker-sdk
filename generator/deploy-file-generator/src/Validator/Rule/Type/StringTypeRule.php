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
    protected const VALIDATION_MESSAGE_TEMPLATE = '`%s` should be String.';

    /**
     * @param string $validateField
     * @param array $data
     *
     * @return bool
     */
    public function isValid(string $validateField, array $data): bool
    {
        if (!Arr::has($data, $validateField)) {
            return true;
        }

        return is_string(data_get($data, $validateField));
    }
}
