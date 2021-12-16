<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Transfer\Validation\Field;

class ValidationFieldCollectionTransfer
{
    /**
     * @var array<\DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer>
     */
    protected $fields = [];

    /**
     * @return array<\DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer>
     */
    public function getFields(): array
    {
        return $this->fields;
    }

    /**
     * @param array<\DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer> $fields
     *
     * @return $this
     */
    public function setFields(array $fields)
    {
        $this->fields = $fields;

        return $this;
    }

    /**
     * @param \DeployFileGenerator\Transfer\Validation\Field\ValidationFieldTransfer $validationFieldTransfer
     *
     * @return $this
     */
    public function addField(ValidationFieldTransfer $validationFieldTransfer)
    {
        $this->fields[] = $validationFieldTransfer;

        return $this;
    }
}
