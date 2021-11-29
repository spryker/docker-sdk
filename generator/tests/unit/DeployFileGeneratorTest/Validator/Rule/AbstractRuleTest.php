<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Validator\Rule;

use Codeception\Test\Unit;
use DeployFileGenerator\Validator\Rule\AbstractRule;
use DeployFileGenerator\Validator\Rule\RuleInterface;
use RuntimeException;

abstract class AbstractRuleTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @dataProvider dataProvider
     *
     * @param string $key
     * @param array $data
     * @param bool $exceptedResult
     *
     * @return void
     */
    public function testIsValid(string $key, array $data, bool $exceptedResult): void
    {
        $this->tester->assertSame($exceptedResult, $this->createRule()->isValid($key, $data));
    }

    /**
     * @return void
     */
    public function testGetRuleName(): void
    {
        /** @var \DeployFileGenerator\Validator\Rule\AbstractRule $ruleInstance */
        $ruleInstance = $this->createRule();

        $this->tester->assertSame(
            $ruleInstance::RULE_NAME,
            $ruleInstance->getRuleName(),
        );

        $ruleInstance = $this->make(AbstractRule::class);
        $this->tester->expectThrowable(
            RuntimeException::class,
            function () use ($ruleInstance) {
                $ruleInstance->getRuleName();
            },
        );
    }

    /**
     * @return void
     */
    public function testGetValidationMessage(): void
    {
        /** @var \DeployFileGenerator\Validator\Rule\AbstractRule $ruleInstance */
        $ruleInstance = $this->createRule();
        $testFieldName = 'test-field';
        $validationMessage = sprintf($ruleInstance::VALIDATION_MESSAGE_TEMPLATE, $testFieldName);

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
     * @return array
     */
    abstract public function dataProvider(): array;

    /**
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    abstract protected function createRule(): RuleInterface;
}
