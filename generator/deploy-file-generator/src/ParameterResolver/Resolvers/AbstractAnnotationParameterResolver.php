<?php

namespace DeployFileGenerator\ParameterResolver\Resolvers;

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

        /*todo: skip error if empty match*/
        if (!isset($params[$param])) {
            return $value;
        }

        return str_replace($match[0], $params[$param], $value);
    }
}