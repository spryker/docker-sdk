<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Validator\Rule;

use DeployFileGenerator\Validator\Rule\AbstractRule;
use DeployFileGenerator\Validator\Rule\RangeValueRule;
use DeployFileGenerator\Validator\Rule\RuleInterface;
use RuntimeException;

class RangeValueRuleTest extends AbstractRuleTest
{
    /**
     * @var int
     */
    protected const MIN_VALUE = 1;

    /**
     * @var int
     */
    protected const MAX_VALUE = 6;

    /**
     * @return array<array>
     */
    public function dataProvider(): array
    {
        // Arrange
        return [
            ['key', ['key' => rand(static::MIN_VALUE, static::MAX_VALUE) - 1], true],
            ['key', ['key' => 'str'], true],
            ['key', ['other' => 'str'], true],
            ['key.*.inner', ['key' => ['some' => ['inner' => []]]], true],
            ['key.*.inner', ['key' => []], true],
            ['key.*.inner', ['key' => ['some' => ['inner' => static::MAX_VALUE + rand(1, 100)]]], false],
            ['key', ['key' => static::MAX_VALUE + rand(1, 100)], false],
        ];
    }

    /**
     * @return void
     */
    public function testGetValidationMessage(): void
    {
        /** @var \DeployFileGenerator\Validator\Rule\AbstractRule $ruleInstance */
        $ruleInstance = $this->createRule();
        $testFieldName = 'test-field';
        $validationMessage = sprintf(
            $ruleInstance::VALIDATION_MESSAGE_TEMPLATE,
            $testFieldName,
            static::MIN_VALUE . '...' . static::MAX_VALUE,
        );

        $this->tester->assertSame(
            $validationMessage,
            $ruleInstance->getValidationMessage($testFieldName),
        );

        $ruleInstance = $this->make(AbstractRule::class);
        $this->tester->expectThrowable(
            RuntimeException::class,
            function () use ($ruleInstance, $testFieldName) {
                $ruleInstance->getValidationMessage($testFieldName);
            },
        );
    }

    /**
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    protected function createRule(): RuleInterface
    {
        return new RangeValueRule([static::MIN_VALUE, static::MAX_VALUE]);
    }
}
