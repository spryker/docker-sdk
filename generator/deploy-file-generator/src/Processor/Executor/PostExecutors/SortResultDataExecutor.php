<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Processor\Executor\PostExecutors;

use DeployFileGenerator\DeployFileGeneratorConfig;
use DeployFileGenerator\Processor\Executor\ExecutorInterface;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class SortResultDataExecutor implements ExecutorInterface
{
    /**
     * @var \DeployFileGenerator\DeployFileGeneratorConfig
     */
    protected $config;

    /**
     * @param \DeployFileGenerator\DeployFileGeneratorConfig
     */
    public function __construct(DeployFileGeneratorConfig $config)
    {
        $this->config = $config;
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

        foreach ($this->config->getDeployFileOutputOrderKeys() as $deployFileOutputOrderKey) {
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
