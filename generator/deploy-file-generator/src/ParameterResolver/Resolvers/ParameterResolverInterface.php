<?php

namespace DeployFileGenerator\ParameterResolver\Resolvers;

interface ParameterResolverInterface
{
    /**
     * @param mixed $value
     * @param array $params
     *
     * @return mixed
     */
    public function resolveValue($value, array $params = []);
}