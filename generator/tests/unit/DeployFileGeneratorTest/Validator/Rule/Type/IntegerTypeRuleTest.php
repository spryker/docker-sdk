<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGenerator\Validator\Rule\Type;

use DeployFileGenerator\Validator\Rule\RuleInterface;
use DeployFileGenerator\Validator\Rule\Type\IntegerTypeRule;
use Unit\DeployFileGenerator\Validator\Rule\AbstractRuleTest;

class IntegerTypeRuleTest extends AbstractRuleTest
{
    public function dataProvider(): array
    {
        return [
            ['key', ['key' => 1], true],
            ['key', ['key' => 'str'], false],
            ['key', ['key' => ['first-key' => 123]], false],
            ['key', ['key' => true], false],
        ];
    }

    protected function createRule(): RuleInterface
    {
        return new IntegerTypeRule();
    }
}
