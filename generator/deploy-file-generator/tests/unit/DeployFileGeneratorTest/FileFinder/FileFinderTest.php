<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Unit\DeployFileGeneratorTest\FileFinder;

use Codeception\Test\Unit;
use DeployFileGenerator\DeployFileGeneratorConfig;
use DeployFileGenerator\FileFinder\FileFinder;
use DeployFileGenerator\FileFinder\FileFinderInterface;

class FileFinderTest extends Unit
{
    /**
     * @var string
     */
    protected const BASE_PATH = './deploy-file-generator/tests/_output/base/';

    /**
     * @var string
     */
    protected const PROJECT_PATH = './deploy-file-generator/tests/_output/project/';

    /**
     * @var string
     */
    protected const FILE_NAME = 'deploy.yml';

    /**
     * @var \UnitTester
     */
    protected $tester;

    /**
     * @return void
     */
    public function testGetFilePathOnProjectLayer(): void
    {
        // Arrange, Act
        $filePath = $this->createFileFinder()->getFilePathOnProjectLayer(static::FILE_NAME);

        // Assert
        $this->tester->assertFileExists($filePath);
    }

    /**
     * @return void
     */
    public function testGetFilePathOnBaseLayer(): void
    {
        // Arrange, Act
        $filePath = $this->createFileFinder()->getFilePathOnBaseLayer(static::FILE_NAME);

        // Assert
        $this->tester->assertFileExists($filePath);
    }

    /**
     * @return void
     */
    protected function _before(): void
    {
        mkdir(static::BASE_PATH);
        mkdir(static::PROJECT_PATH);

        file_put_contents(static::BASE_PATH . static::FILE_NAME, '');
        file_put_contents(static::PROJECT_PATH . static::FILE_NAME, '');
    }

    /**
     * @return void
     */
    protected function _after(): void
    {
        unlink(static::BASE_PATH . static::FILE_NAME);
        unlink(static::PROJECT_PATH . static::FILE_NAME);

        rmdir(static::BASE_PATH);
        rmdir(static::PROJECT_PATH);
    }

    /**
     * @return \DeployFileGenerator\FileFinder\FileFinderInterface
     */
    protected function createFileFinder(): FileFinderInterface
    {
        $configMock = $this->make(DeployFileGeneratorConfig::class, [
            'getProjectDirectoryPath' => self::PROJECT_PATH,
            'getBaseDirectoryPath' => self::BASE_PATH,
        ]);

        return new FileFinder($configMock);
    }
}
