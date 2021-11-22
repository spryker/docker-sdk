<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Cleaner;

use DeployFileGenerator\Transfer\DeployFileTransfer;

class Cleaner implements CleanerInterface
{
    /**
     * @var array<\DeployFileGenerator\Cleaner\CleanerInterface>
     */
    protected $cleanerCollection;

    /**
     * @param array<\DeployFileGenerator\Cleaner\CleanerInterface> $cleanerCollection
     */
    public function __construct(array $cleanerCollection = [])
    {
        $this->cleanerCollection = $cleanerCollection;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function clean(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        foreach ($this->cleanerCollection as $cleaner) {
            $deployFileTransfer = $cleaner->clean($deployFileTransfer);
        }

        return $deployFileTransfer;
    }
}
