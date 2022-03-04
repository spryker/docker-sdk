<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Builder;

use DeployFileGenerator\Transfer\Validation\Field\ValidationFieldCollectionTransfer;

interface ValidationFieldCollectionBuilderInterface
{
    /**
     * @return \DeployFileGenerator\Transfer\Validation\Field\ValidationFieldCollectionTransfer
     */
    public function buildValidationFieldCollection(): ValidationFieldCollectionTransfer;
}
