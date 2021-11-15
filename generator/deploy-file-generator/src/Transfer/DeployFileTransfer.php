<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Transfer;

use DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer;

class DeployFileTransfer
{
    /**
     * @var array
     */
    protected $rawData = [];

    /**
     * @var array
     */
    protected $resultData = [];

    /**
     * @var string
     */
    protected $inputFilePath = '';

    /**
     * @var string
     */
    protected $outputFilePath = '';

    /**
     * @var array<string, array|null>
     */
    protected $projectImports = [];

    /**
     * @var array<string, array|null>
     */
    protected $baseImports = [];

    /**
     * @var \DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer
     */
    protected $validationMessageBagTransfer;

    /**
     * @return array
     */
    public function getRawData(): array
    {
        return $this->rawData;
    }

    /**
     * @param array $rawData
     *
     * @return $this
     */
    public function setRawData(array $rawData)
    {
        $this->rawData = $rawData;

        return $this;
    }

    /**
     * @return array
     */
    public function getResultData(): array
    {
        return $this->resultData;
    }

    /**
     * @param array $resultData
     *
     * @return $this
     */
    public function setResultData(array $resultData)
    {
        $this->resultData = $resultData;

        return $this;
    }

    /**
     * @return string
     */
    public function getInputFilePath(): string
    {
        return $this->inputFilePath;
    }

    /**
     * @param string $inputFilePath
     *
     * @return $this
     */
    public function setInputFilePath(string $inputFilePath)
    {
        $this->inputFilePath = $inputFilePath;

        return $this;
    }

    /**
     * @return string
     */
    public function getOutputFilePath(): string
    {
        return $this->outputFilePath;
    }

    /**
     * @param string $outputFilePath
     *
     * @return $this
     */
    public function setOutputFilePath(string $outputFilePath)
    {
        $this->outputFilePath = $outputFilePath;

        return $this;
    }

    /**
     * @return array<string, array|null>
     */
    public function getProjectImports(): array
    {
        return $this->projectImports;
    }

    /**
     * @param array<string, array|null> $projectImports
     *
     * @return $this
     */
    public function setProjectImports(array $projectImports)
    {
        $this->projectImports = $projectImports;

        return $this;
    }

    /**
     * @return array<string, array|null>
     */
    public function getBaseImports(): array
    {
        return $this->baseImports;
    }

    /**
     * @param array<string, array|null> $baseImports
     *
     * @return $this
     */
    public function setBaseImports(array $baseImports)
    {
        $this->baseImports = $baseImports;

        return $this;
    }

    /**
     * @return \DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer
     */
    public function getValidationMessageBagTransfer(): ValidationMessageBagTransfer
    {
        return $this->validationMessageBagTransfer;
    }

    /**
     * @param \DeployFileGenerator\Transfer\Validation\Message\ValidationMessageBagTransfer $validationMessageBagTransfer
     *
     * @return $this
     */
    public function setValidationMessageBagTransfer(ValidationMessageBagTransfer $validationMessageBagTransfer)
    {
        $this->validationMessageBagTransfer = $validationMessageBagTransfer;

        return $this;
    }
}
