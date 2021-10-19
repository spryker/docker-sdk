<?php

namespace DeployFileGenerator\ParameterResolver\Resolvers;

class PercentAnnotationParameterResolver extends AbstractAnnotationParameterResolver
{
    /**
     * @return string
     */
    public function getAnnotationTemplate(): string
    {
        return '/\%([^%\s]+)\%/';
    }
}