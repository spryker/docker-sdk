<?php


/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Importer;

interface DeployFileImporterInterface
{
    /**
     * @param string $filePath
     * @param array $parameters
     *
     * @return array
     */
    public function importFromFile(string $filePath, array $parameters = []): array;

    /**
     * @param array $data
     * @param array $parameters
     *
     * @return array
     */
    public function importFromData(array $data, array $parameters = []): array;
}
