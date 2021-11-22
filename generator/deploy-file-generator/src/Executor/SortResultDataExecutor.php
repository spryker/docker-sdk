<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Executor;

use DeployFileGenerator\Transfer\DeployFileTransfer;

class SortResultDataExecutor implements ExecutorInterface
{
    /**
     * @var array<string>
     */
    protected $deployFileOutputOrderKeys;

    /**
     * @param array<string> $deployFileOutputOrderKeys
     */
    public function __construct(array $deployFileOutputOrderKeys)
    {
        $this->deployFileOutputOrderKeys = $deployFileOutputOrderKeys;
    }

    /**
     * @param \DeployFileGenerator\Transfer\DeployFileTransfer $deployFileTransfer
     *
     * @return \DeployFileGenerator\Transfer\DeployFileTransfer
     */
    public function execute(DeployFileTransfer $deployFileTransfer): DeployFileTransfer
    {
        $sortedResult = [];
        $resultData = $deployFileTransfer->getResultData();

        foreach ($this->deployFileOutputOrderKeys as $deployFileOutputOrderKey) {
            if (!array_key_exists($deployFileOutputOrderKey, $resultData)) {
                continue;
            }

            $sortedResult[$deployFileOutputOrderKey] = $resultData[$deployFileOutputOrderKey];
            unset($resultData[$deployFileOutputOrderKey]);
        }

        if ($resultData !== []) {
            $sortedResult = array_merge($sortedResult, $resultData);
        }

        $deployFileTransfer = $deployFileTransfer->setResultData($sortedResult);

        return $deployFileTransfer;
    }
}
