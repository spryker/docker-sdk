<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\Validator\Rule;

use DeployFileGenerator\Validator\Rule\GroupRegionRule;
use DeployFileGenerator\Validator\Rule\RuleInterface;

class GroupRegionRuleTest extends AbstractRuleTest
{
    /**
     * @return array<array>
     */
    public function dataProvider(): array
    {
        // Arrange
        return [
            ['groups.*.region', ['regions' => ['EU' => []], 'groups' => ['some-group' => ['region' => 'EU']]], true],
            ['groups.*.region', ['regions' => ['EU' => []], 'groups' => []], true],
            ['groups.some-group.region', ['regions' => ['EU' => []], 'groups' => ['some-group' => ['region' => 'EU']]], true],
            ['groups.*.region', ['regions' => ['DE' => []], 'groups' => ['some-group' => ['region' => 'EU']]], false],
            ['groups.some-group.region', ['regions' => ['DE' => []], 'groups' => ['group' => ['region' => 'EU']]], true],
        ];
    }

    /**
     * @return \DeployFileGenerator\Validator\Rule\RuleInterface
     */
    protected function createRule(): RuleInterface
    {
        return new GroupRegionRule();
    }
}
