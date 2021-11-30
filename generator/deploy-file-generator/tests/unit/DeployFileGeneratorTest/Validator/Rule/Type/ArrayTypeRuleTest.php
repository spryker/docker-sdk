<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Validator\Rule\Type;

use DeployFileGenerator\Validator\Rule\RuleInterface;
use DeployFileGenerator\Validator\Rule\Type\ArrayTypeRule;
use Unit\DeployFileGeneratorTest\Validator\Rule\AbstractRuleTest;

class ArrayTypeRuleTest extends AbstractRuleTest
{
    /**
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    protected function createRule(): RuleInterface
    {
        return new ArrayTypeRule();
    }

    /**
     * @return array<array>
     */
    public function dataProvider(): array
    {
        // Arrange
        return [
            ['test-key', ['test-key' => [2]], true],
            ['test-key', ['other-key' => [2]], true],
            ['test-key.*.inner-key', [
                'test-key' => [
                    'first-key' => ['inner-key' => [2]],
                    'second-key' => ['inner-key' => [2]],
                    'third-key' => ['inner-key' => null],
                ],
            ], true],
            ['test-key.*.inner-key', ['other-key' => []], true],

            ['test-key', ['test-key' => 'str'], false],
            ['test-key.*.inner-key', [
                'test-key' => [
                    'first-key' => ['inner-key' => [2]],
                    'second-key' => ['inner-key' => 3],
                    'third-key' => ['inner-key' => null],
                ],
            ], false],
        ];
    }
}
