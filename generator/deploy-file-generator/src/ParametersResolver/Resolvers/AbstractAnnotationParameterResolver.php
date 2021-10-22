<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\ParametersResolver\Resolvers;

abstract class AbstractAnnotationParameterResolver implements ParameterResolverInterface, AnnotationParameterResolverInterface
{
    /**
     * @param mixed $value
     * @param array $params
     *
     * @return mixed
     */
    public function resolveValue($value, array $params = [])
    {
        if (!is_string($value)) {
            return $value;
        }

        preg_match($this->getAnnotationTemplate(), $value, $match);

        if (!$match) {
            return $value;
        }

        $param = $match[1];

        /* skip error if empty match*/
        if (!isset($params[$param])) {
            return $value;
        }

        return str_replace($match[0], $params[$param], $value);
    }
}
