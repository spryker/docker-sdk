<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGenerator\Validator\Rule;

use Codeception\Test\Unit;
use DeployFileGenerator\Validator\Rule\RuleInterface;

abstract class AbstractRuleTest extends Unit
{
    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @dataProvider dataProvider
     *
     * @return void
     */
    public function testIsValid(string $key, array $data, bool $exceptedResult): void
    {
        $this->tester->assertSame($exceptedResult, $this->createRule()->isValid($key, $data));
    }

    abstract public function dataProvider(): array;
    abstract protected function createRule(): RuleInterface;
}
