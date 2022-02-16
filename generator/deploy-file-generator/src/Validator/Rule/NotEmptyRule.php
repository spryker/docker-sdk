<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use Illuminate\Support\Arr;

class NotEmptyRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'not-empty';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should not be empty.';

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

        return !empty(data_get($data, $validateField));
    }
}
