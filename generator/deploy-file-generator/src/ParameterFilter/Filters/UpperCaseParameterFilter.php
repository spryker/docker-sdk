<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\ParameterFilter\Filters;

use DeployFileGenerator\ParameterFilter\ParameterFilterInterface;

class UpperCaseParameterFilter implements ParameterFilterInterface
{
    /**
     * @return string
     */
    protected const FILTER_NAME = 'upper';

    /**
     * @return string
     */
    public function getFilterName(): string
    {
        return static::FILTER_NAME;
    }

    /**
     * @param string $value
     *
     * @return string
     */
    public function filter(string $value): string
    {
        return strtoupper($value);
    }
}
