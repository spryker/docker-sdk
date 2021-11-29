<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use Illuminate\Support\Arr;

class RequireRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'require';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` is required.';

    /**
     * @param string $validateField
     * @param array $data
     *
     * @return bool
     */
    public function isValid(string $validateField, array $data): bool
    {
        if (!$this->isWildCardFieldName($validateField)) {
            return Arr::has($data, $validateField);
        }

        $data = data_get($data, $validateField);

        foreach ($data as $item) {
            if ($item == null) {
                return false;
            }
        }

        return true;
    }
}
