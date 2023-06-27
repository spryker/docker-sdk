<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace ProjectData;

use ProjectData\DataBuilder\DataBuilder\DataBuilderStrategyInterface;
use ProjectData\DataBuilder\MultiStore\Executor\BrokerHostsExecutor as MultiStoreBrokerHostsExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\DynamicStoreModeExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\StorageDataExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\StoreSpecific\StoreSpecificBrokerExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\StoreSpecific\StoreSpecificKeyValueStoreExecutor;
use ProjectData\DataBuilder\MultiStore\Executor\StoreSpecific\StoreSpecificSessionExecutor;
use ProjectData\DataBuilder\MultiStore\MultiStoreDataBuilderStrategy;
use ProjectData\DataBuilder\ProjectData\Executor\BrokerConnectionsExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\BrokerHostsExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\CloudBrokerConnectionsExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\EndpointIdentifierExecutor;
use ProjectData\DataBuilder\ProjectData\Executor\KeyValueStoreConnectionsExecutor;
use ProjectData\DataBuilder\ProjectData\ProjectDataBuilderStrategy;
use ProjectData\DataBuilder\ProjectDataBuildProcessor;

class ProjectDataFactory
{

    /**
     * @return \ProjectData\DataBuilder\ProjectDataBuildProcessor
     */
    public function createProjectDataBuildProcessor(): ProjectDataBuildProcessor
    {
        return new ProjectDataBuildProcessor([
            $this->createProjectDataBuilderStrategy(),
            $this->createMultiStoreDataBuilderStrategy(),
        ]);
    }

    /**
     * @return \ProjectData\DataBuilder\DataBuilder\DataBuilderStrategyInterface
     */
    public function createMultiStoreDataBuilderStrategy(): DataBuilderStrategyInterface
    {
        return new MultiStoreDataBuilderStrategy(
            $this->getMultiStoreExecutorList(),
        );
    }

    /**
     * @return \ProjectData\DataBuilder\DataExecutor\DataExecutorInterface[]
     */
    public function getMultiStoreExecutorList(): array
    {
        return [
            new MultiStoreBrokerHostsExecutor(),
            new DynamicStoreModeExecutor(),
            new StoreSpecificBrokerExecutor(),
            new StoreSpecificKeyValueStoreExecutor(),
            new StoreSpecificSessionExecutor(),
            new StorageDataExecutor(),
        ];
    }

    /**
     * @return \ProjectData\DataBuilder\DataBuilder\DataBuilderStrategyInterface
     */
    public function createProjectDataBuilderStrategy(): DataBuilderStrategyInterface
    {
        return new ProjectDataBuilderStrategy(
            $this->getProjectDataExecutorList()
        );
    }

    /**
     * @return \ProjectData\DataBuilder\DataExecutor\DataExecutorInterface[]
     */
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
