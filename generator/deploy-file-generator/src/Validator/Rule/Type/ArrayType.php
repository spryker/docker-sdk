<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule\Type;

use DeployFileGenerator\Validator\Rule\AbstractRule;

class ArrayType extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'array-type';

    /**
     * @var string
     */
    protected const VALIDATION_MESSAGE_TEMPLATE = '`%s` should be Array.';

    /**
     * @param string $validateField
     * @param array $data
     *
     * @return bool
     */
    public function isValid(string $validateField, array $data): bool
    {
        return is_array(data_get($data, $validateField));
    }
}
