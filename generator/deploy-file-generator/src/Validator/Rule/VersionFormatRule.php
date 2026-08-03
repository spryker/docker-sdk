<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use DeployFileGenerator\Validator\Rule\AbstractRule;
use Illuminate\Support\Arr;

class VersionFormatRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'version-format';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should be a valid version format (e.g., "18", "18.20", "18.20.0").';

    /**
     * Version format regex: allows integers or semantic version format (x, x.y, x.y.z)
     * Examples: 18, "18", "18.20", "18.20.0", "20.11.0"
     *
     * @var string
     */
    protected const VERSION_PATTERN = '/^(\d+)(\.\d+)?(\.\d+)?$/';

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
            return $this->isValidVersion($data);
        }

        foreach ($data as $item) {
            if ($item !== null && !$this->isValidVersion($item)) {
                return false;
            }
        }

        return true;
    }

    /**
     * @param mixed $value
     *
     * @return bool
     */
    protected function isValidVersion($value): bool
    {
        if (is_int($value)) {
            return $value > 0;
        }

        if (is_string($value)) {
            return (bool)preg_match(self::VERSION_PATTERN, $value);
        }

        return false;
    }
}

