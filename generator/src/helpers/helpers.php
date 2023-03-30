<?php

const PROJECT_DATA_REGIONS_KEY = 'regions';
const PROJECT_DATA_REGION_KEY = 'region';
const PROJECT_DATA_GROUPS_KEY = 'groups';
const PROJECT_DATA_STORE_KEY = 'stores';
const PROJECT_DATA_SERVICES_KEY = 'services';
const PROJECT_DATA_BROKER_KEY = 'broker';
const PROJECT_DATA_NAMESPACE_KEY = 'namespace';
const PROJECT_DATA_KEY_VALUE_STORE_KEY = 'key_value_store';
const PROJECT_DATA_SESSION_KEY = 'session';

/**
 * @param array $projectData
 *
 * @return array
 */
function getRegionSpecific(array $projectData): array
{
    $regionSpecific = [];
    foreach ($projectData[PROJECT_DATA_REGIONS_KEY] as $regionName => $regionData) {
        $services = $regionData[PROJECT_DATA_SERVICES_KEY];

        if (isset($services[PROJECT_DATA_KEY_VALUE_STORE_KEY][PROJECT_DATA_NAMESPACE_KEY])) {
            $regionSpecific[$regionName]['SPRYKER_KEY_VALUE_STORE_NAMESPACE'] = $services[PROJECT_DATA_KEY_VALUE_STORE_KEY][PROJECT_DATA_NAMESPACE_KEY];
        }
        if (isset($services[PROJECT_DATA_BROKER_KEY][PROJECT_DATA_NAMESPACE_KEY])) {
            $regionSpecific[$regionName]['SPRYKER_BROKER_NAMESPACE'] = $services[PROJECT_DATA_BROKER_KEY][PROJECT_DATA_NAMESPACE_KEY];
        }
        if (isset($services[PROJECT_DATA_SESSION_KEY][PROJECT_DATA_NAMESPACE_KEY])) {
            $regionSpecific[$regionName]['SPRYKER_SESSION_BE_NAMESPACE'] = $services[PROJECT_DATA_SESSION_KEY][PROJECT_DATA_NAMESPACE_KEY];
        }
    }

    return $regionSpecific;
}

/**
 * @param array $projectData
 *
 * @return string
 */
function getKeyValueStores(array $projectData): string
{
    $keyValueStoreData = $projectData[PROJECT_DATA_SERVICES_KEY][PROJECT_DATA_KEY_VALUE_STORE_KEY];

    $connections = [];
    foreach ($projectData[PROJECT_DATA_REGIONS_KEY] as $regionName => $regionData) {
        $regionKeyValueStoreData = $keyValueStoreData;
        if (isset($regionData[PROJECT_DATA_SERVICES_KEY][PROJECT_DATA_KEY_VALUE_STORE_KEY])) {
            $connections[$regionName] = $regionKeyValueStoreData = array_replace($regionKeyValueStoreData, $regionData[PROJECT_DATA_SERVICES_KEY][PROJECT_DATA_KEY_VALUE_STORE_KEY]);
        }
        foreach ($regionData[PROJECT_DATA_STORE_KEY] ?? [] as $storeName => $storeData) {
            if (!isset($storeData[PROJECT_DATA_SERVICES_KEY][PROJECT_DATA_KEY_VALUE_STORE_KEY])) {
                continue;
            }
            $connections[$storeName] = array_replace($regionKeyValueStoreData, $storeData[PROJECT_DATA_SERVICES_KEY][PROJECT_DATA_KEY_VALUE_STORE_KEY]);
        }
    }

    return json_encode($connections);
}

/**
 * @param array $projectData
 * @param string $currentRegion
 *
 * @return string
 */
function getBrokerHosts(array $projectData, string $currentRegion = ''): string
{
    $hosts = null;
    $storesData = $projectData[PROJECT_DATA_REGIONS_KEY][$currentRegion][PROJECT_DATA_STORE_KEY] ?? null;

    if ($storesData !== null) {
        $hosts = getBrokerHostNamesMap($storesData);
    }

    if ($hosts === null) {
        $hosts = [];
        foreach ($projectData[PROJECT_DATA_REGIONS_KEY] as $config) {
            if (!isset($config[PROJECT_DATA_STORE_KEY])) {
                continue;
            }
            $regionStores = array_values($config[PROJECT_DATA_STORE_KEY]);
            array_walk($regionStores, function(array $store) use (&$hosts) {
                $namespace = $store[PROJECT_DATA_SERVICES_KEY][PROJECT_DATA_BROKER_KEY][PROJECT_DATA_NAMESPACE_KEY] ?? '';
                array_push($hosts, $namespace);
            });
        }
        if (!count($hosts)) {
            $hosts = getBrokerHostNamesMap($projectData[PROJECT_DATA_REGIONS_KEY]);
        }
    }

    return implode(' ', array_values($hosts));
}

/**
 * @param array $projectData
 *
 * @return string
 */
function getDefaultRegionName($projectData): string
{
    $keys = array_keys(PROJECT_DATA_GROUPS_KEY);

    return $projectData[PROJECT_DATA_GROUPS_KEY][array_pop($keys)][PROJECT_DATA_REGION_KEY] ?? '';
}


