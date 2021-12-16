<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\ParametersResolver;

interface ParametersResolverInterface
{
    /**
     * @param array $content
     * @param array $params
     *
     * @return array
     */
    public function resolveParams(array $content, array $params = []): array;
}
