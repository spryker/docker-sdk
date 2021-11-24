<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\FileFinder;

interface FileFinderInterface
{
    /**
     * @param string $fileName
     *
     * @return string|null
     */
    public function getFilePathOnBaseLayer(string $fileName): ?string;

    /**
     * @param string $fileName
     *
     * @return string|null
     */
    public function getFilePathOnProjectLayer(string $fileName): ?string;
}
