<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Validator\Rule;

use DeployFileGenerator\Validator\Rule\NotEmptyRule;
use DeployFileGenerator\Validator\Rule\RuleInterface;

class NotEmptyRuleTest extends AbstractRuleTest
{
    /**
     * @return array<array>
     */
    public function dataProvider(): array
    {
        // Arrange
        return [
            ['key', ['key' => 1], true],
            ['key', ['key' => 'str'], true],
            ['key', ['key' => [1]], true],
            ['key', ['other-key' => 1], true],
            ['key', ['key' => []], false],
        ];
    }

    /**
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    protected function createRule(): RuleInterface
    {
        return new NotEmptyRule();
    }
}
