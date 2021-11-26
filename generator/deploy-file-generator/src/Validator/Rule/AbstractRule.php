<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Validator\Rule;

use RuntimeException;

abstract class AbstractRule implements RuleInterface
{
    /**
     * @var string
     */
    public const RULE_NAME = '';

    /**
     * @var string
     */
    public const VALIDATION_MESSAGE_TEMPLATE = '';

    /**
     * @var array
     */
    protected $ruleConfig;

    /**
     * @param array $ruleConfig
     */
    public function __construct(array $ruleConfig = [])
    {
        $this->ruleConfig = $ruleConfig;
    }

    /**
     * @throws \RuntimeException
     *
     * @return string
     */
    public function getRuleName(): string
    {
        if (static::RULE_NAME == '') {
            throw new RuntimeException('RULE_NAME constant should not be empty.');
        }

        return static::RULE_NAME;
    }

    /**
     * @param string $fieldName
     *
     * @throws \RuntimeException
     *
     * @return string
     */
    public function getValidationMessage(string $fieldName): string
    {
        if (static::VALIDATION_MESSAGE_TEMPLATE == '') {
            throw new RuntimeException('VALIDATION_MESSAGE_TEMPLATE constant should not be empty.');
        }

        return sprintf(static::VALIDATION_MESSAGE_TEMPLATE, $fieldName);
    }

    /**
     * @param string $fieldName
     *
     * @return bool
     */
    protected function isWildCardFieldName(string $fieldName): bool
    {
        return strpos($fieldName, '*') !== false;
    }
}
