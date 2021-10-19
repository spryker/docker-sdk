<?php

namespace DeployFileGenerator\ParameterResolver\Resolvers;

interface AnnotationParameterResolverInterface
{
    /**
     * @return string
     */
    public function getAnnotationTemplate(): string;
}