<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\ParametersResolver;

class ParametersResolver implements ParametersResolverInterface
{
    /**
     * @var array<\DeployFileGenerator\ParametersResolver\Resolvers\ParameterResolverInterface>
     */
    protected $resolvers;

    /**
     * @param array<\DeployFileGenerator\ParametersResolver\Resolvers\ParameterResolverInterface> $resolvers
     */
    public function __construct(array $resolvers)
    {
        $this->resolvers = $resolvers;
    }

    /**
     * @param array $content
     * @param array $params
     *
     * @return array
     */
    public function resolveParams(array $content, array $params = []): array
    {
        foreach ($content as $key => $value) {
            $resolvedKey = $this->resolve($key, $params);
            $resolvedValue = $this->resolve($value, $params);

            if ($key !== $resolvedKey) {
                unset($content[$key]);
            }

            $content[$resolvedKey] = $resolvedValue;
        }

        return $content;
    }

    /**
     * @param mixed $value
     * @param array $params
     *
     * @return mixed
     */
    protected function resolve($value, array $params = [])
    {
        if (is_array($value)) {
            return $this->resolveParams($value, $params);
        }

        foreach ($this->resolvers as $resolver) {
            $value = $resolver->resolveValue($value, $params);
        }

        return $value;
    }
}
