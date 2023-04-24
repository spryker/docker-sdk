<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData;

use ProjectData\DataBuilder\DataBuilder\DataBuilderInterface;
use ProjectData\DataBuilder\MultiStore\Executor\BrokerHostsExecutor as MultiStoreBrokerHostsExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\DynamicStoreModeExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\EntrypointIdentifierExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\StorageDataExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\StoreSpecificExecutor;
use ProjectData\DataBuilder\MultiStore\MultiStoreDataBuilder;
use ProjectData\DataBuilder\ProjectData\Executor\BrokerConnectionsExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\BrokerHostsExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\CloudBrokerConnectionsExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\EndpointIdentifierExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\KeyValueStoreConnectionsExecutor;
use ProjectData\DataBuilder\ProjectData\ProjectDataBuilder;
use ProjectData\DataBuilder\ProjectDataBuildProcessor;

class ProjectDataFactory
{

    public function createProjectDataBuildProcessor(): ProjectDataBuildProcessor
    {
        return new ProjectDataBuildProcessor([
            $this->createProjectDataBuilder(),
            $this->createMultiStoreDataBuilder(),
        ]);
    }

    public function createMultiStoreDataBuilder(): DataBuilderInterface
    {
        return new MultiStoreDataBuilder(
            $this->getMultiStoreExecutorList(),
        );
    }

    public function getMultiStoreExecutorList(): array
    {
        return [
            new MultiStoreBrokerHostsExecutor(),
            new DynamicStoreModeExecutor(),
            new StoreSpecificExecutor(),
            new EntrypointIdentifierExecutor(),
            new StorageDataExecutor(),
        ];
    }

    public function createProjectDataBuilder(): DataBuilderInterface
    {
        return new ProjectDataBuilder(
            $this->getProjectDataExecutorList()
        );
    }

    public function getProjectDataExecutorList(): array
    {
        return [
            new BrokerHostsExecutor(),
            new KeyValueStoreConnectionsExecutor(),
            new BrokerConnectionsExecutor(),
            new EndpointIdentifierExecutor(),
            new CloudBrokerConnectionsExecutor(),
        ];
    }
}
