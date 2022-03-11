<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\ParameterFilter;

interface ParameterFilterInterface
{
    /**
     * @return string
     */
    public function getFilterName(): string;

    /**
     * @param string $value
     *
     * @return string
     */
    public function filter(string $value): string;
}
