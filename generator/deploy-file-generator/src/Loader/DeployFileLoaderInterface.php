<?php

namespace DeployFileGenerator\Loader;

interface DeployFileLoaderInterface
{
    /**
     * @param string $resource
     * @param array $parameters
     *
     * @return array
     */
    public function load(string $resource, array $parameters = []): array;
}