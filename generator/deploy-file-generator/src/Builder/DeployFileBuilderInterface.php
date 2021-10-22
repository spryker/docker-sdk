<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Builder;

interface DeployFileBuilderInterface
{
    /**
     * @param string $inputFilePath
     * @param string $outputFilePath
     *
     * @return string
     */
    public function build(string $inputFilePath, string $outputFilePath): string;
}
