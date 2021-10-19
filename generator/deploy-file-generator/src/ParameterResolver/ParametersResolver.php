<?php

namespace DeployFileGenerator\ParameterResolver;


use DeployFileGenerator\ParameterResolver\Resolvers\ParameterResolverInterface;

class ParametersResolver implements ParametersResolverInterface
{
    /**
     * @var ParameterResolverInterface[]
     */
    private $resolvers;

    /**
     * @param ParameterResolverInterface[] $resolvers
     */
    public function __construct(array $resolvers)
    {
        $this->resolvers = $resolvers;
    }

    /**
     * @param array $content
     * @param array $params
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
    private function resolve($value, array $params = [])
    {
        if (is_array($value)) {
            return $this->resolveParams($value, $params);
        }

        foreach ($this->resolvers as $resolver) {
            return $resolver->resolveValue($value, $params);
        }
    }
}
