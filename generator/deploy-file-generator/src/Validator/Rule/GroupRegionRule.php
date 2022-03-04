<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use Illuminate\Support\Arr;

class GroupRegionRule extends AbstractRule
{
    /**
     * @var string
     */
    public const RULE_NAME = 'group-region';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '`%s` should be inited into Region section.';

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

        $regionNames = data_get($data, $validateField);

        if ($regionNames == null) {
            return true;
        }

        if (!$this->isWildCardFieldName($validateField) || !is_array($regionNames)) {
            return Arr::has($data, 'regions.' . $regionNames);
        }

        foreach ($regionNames as $regionName) {
            if (!Arr::has($data, 'regions.' . $regionName)) {
                return false;
            }
        }

        return true;
    }
}
