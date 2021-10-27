<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGeneratorTest\Strategy;

use Codeception\Test\Unit;
use DeployFileGenerator\Executor\ExecutorInterface;
use DeployFileGenerator\Strategy\YamlDeployFileBuildStrategy;
use DeployFileGenerator\Transfer\DeployFileTransfer;

class YamlDeployFileBuildStrategyTest extends Unit
{
    /**
     * @var string
     */
    protected const NEW_INPUT_YAML_PATH = 'new-input-path.yml';
    /**
     * @var string
     */
    protected const INPUT_YAML_PATH = 'input-path.yml';
    /**
     * @var string
     */
    protected const NEW_KEY = 'some_key';
    /**
     * @var string
     */
    protected const NEW_DATA = 'some data';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testExecute(): void
    {
        $strategy = new YamlDeployFileBuildStrategy(
            $this->getExecutorsCollection()
        );

        $deployFileTransfer = new DeployFileTransfer();
        $deployFileTransfer = $deployFileTransfer->setInputFilePath(static::INPUT_YAML_PATH);

        $this->tester->assertEquals(static::INPUT_YAML_PATH, $deployFileTransfer->getInputFilePath());
        $this->tester->assertIsEmpty($deployFileTransfer->getRawData());

        $deployFileTransfer = $strategy->execute($deployFileTransfer);

        $this->tester->assertEquals(static::NEW_INPUT_YAML_PATH, $deployFileTransfer->getInputFilePath());
        $this->tester->assertNotEquals(static::INPUT_YAML_PATH, $deployFileTransfer->getInputFilePath());

        $this->tester->assertEquals([
            static::NEW_KEY => static::NEW_DATA,
        ], $deployFileTransfer->getRawData());
    }

    /**
     * @return array
     */
    protected function getExecutorsCollection(): array
    {
        return [
            $this->makeEmpty(ExecutorInterface::class, [
                'execute' => function (DeployFileTransfer $deployFileTransfer) {
                    return $deployFileTransfer->setInputFilePath(static::NEW_INPUT_YAML_PATH);
                },
            ]),
            $this->makeEmpty(ExecutorInterface::class, [
                'execute' => function (DeployFileTransfer $deployFileTransfer) {
                    $newRawData = $deployFileTransfer->getRawData();
                    $newRawData[static::NEW_KEY] = static::NEW_DATA;

                    return $deployFileTransfer->setRawData($newRawData);
                },
            ]),
        ];
    }
}
