<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Validator\Rule\Type;

use DeployFileGenerator\Validator\Rule\RuleInterface;
use DeployFileGenerator\Validator\Rule\Type\IntegerTypeRule;
use Unit\DeployFileGeneratorTest\Validator\Rule\AbstractRuleTest;

class IntegerTypeRuleTest extends AbstractRuleTest
{
    /**
     * @return array<array>
     */
    public function dataProvider(): array
    {
        // Arrange
        return [
            ['key', ['key' => 1], true],
            ['key', ['key' => 'str'], false],
            ['key', ['key' => ['first-key' => 123]], false],
            ['key', ['key' => true], false],
            ['key', [], true],

            ['key.*.inner-key', ['key' => ['first' => ['inner-key' => 1], 'second' => ['inner-key' => 1]]], true],
            ['key.*.inner-key', ['key' => ['first' => ['inner-key' => 1], 'second' => ['inner-key' => 'str']]], false],
            ['key.*.inner-key', ['key' => ['first' => ['inner-key' => 1], 'second' => []]], true],
            ['key.*.inner-key', [], true],
        ];
    }

    /**
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    protected function createRule(): RuleInterface
    {
        return new IntegerTypeRule();
    }
}
