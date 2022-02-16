<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Validator\Rule\Type;

use DeployFileGenerator\Validator\Rule\RuleInterface;
use DeployFileGenerator\Validator\Rule\Type\StringTypeRule;
use Unit\DeployFileGeneratorTest\Validator\Rule\AbstractRuleTest;

class StringTypeRuleTest extends AbstractRuleTest
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return array<array>
     */
    public function dataProvider(): array
    {
        // Arrange
        return [
            ['key', ['key' => 1], false],
            ['key', ['key' => 'str'], true],
            ['key', ['key' => ['first-key' => 123]], false],
            ['key', ['key' => true], false],
            ['key', [], true],

            ['key.*.inner-key', ['key' => ['first' => ['inner-key' => 'str'], 'second' => ['inner-key' => 'str']]], true],
            ['key.*.inner-key', ['key' => ['first' => ['inner-key' => 1], 'second' => ['inner-key' => 'str']]], false],
            ['key.*.inner-key', ['key' => ['first' => ['inner-key' => 'str'], 'second' => []]], true],
            ['key.*.inner-key', [], true],
        ];
    }

    /**
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    protected function createRule(): RuleInterface
    {
        return new StringTypeRule();
    }
}
