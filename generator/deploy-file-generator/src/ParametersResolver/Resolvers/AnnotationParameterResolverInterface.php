<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\ParametersResolver\Resolvers;

interface AnnotationParameterResolverInterface
{
    /**
     * @return string
     */
    public function getAnnotationTemplate(): string;
}
