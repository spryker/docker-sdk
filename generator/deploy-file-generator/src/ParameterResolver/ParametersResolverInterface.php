<?php

namespace DeployFileGenerator\ParameterResolver;

interface ParametersResolverInterface
{
    /**
     * @param array $content
     * @param array $params
     * @return array
     */
    public function resolveParams(array $content, array $params = []): array;
}