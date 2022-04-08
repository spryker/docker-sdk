<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\ParametersResolver\Resolvers;

use DeployFileGenerator\Exception\ParameterFilterNotExistException;

abstract class AbstractAnnotationParameterResolver implements ParameterResolverInterface, AnnotationParameterResolverInterface
{
    /**
     * @var \DeployFileGenerator\ParameterFilter\ParameterFilterInterface[] $parameterFilters
     */
    protected $parameterFilters;

    /**
     * @param \DeployFileGenerator\ParameterFilter\ParameterFilterInterface[] $parameterFilters
     */
    public function __construct(array $parameterFilters)
    {
        $this->parameterFilters = $parameterFilters;
    }

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

        preg_match_all($this->getAnnotationTemplate(), $value, $match);

        if (!$match[0]) {
            return $value;
        }

        foreach ($match[1] as $key => $param) {
            $filter = null;
            if (strpos($param, '|') !== false) {
                $data = explode('|', $param);
                $param = trim($data[0]);
                $filter = trim($data[1]);
            }

            /* skip error if empty match*/
            if (!isset($params[$param])) {
                continue;
            }

            if ($filter !== null) {
                $params[$param] = $this->applyFilter($params[$param], $filter);
            }

            $value = str_replace($match[0][$key], $params[$param], $value);
        }

        return $value;
    }

    /**
     * @param string $value
     * @param string $filter
     *
     * @throws \DeployFileGenerator\Exception\ParameterFilterNotExistException
     *
     * @return string
     */
    protected function applyFilter(string $value, string $filter): string
    {
        foreach ($this->parameterFilters as $parameterFilter) {
            if ($parameterFilter->getFilterName() === $filter) {
                return $parameterFilter->filter($value);
            }
        }

        throw new ParameterFilterNotExistException(sprintf("Parameter filter `%s` doesn\'t exist.", $filter));
    }
}
