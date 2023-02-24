<?php

/**
 * @param array $projectData
 *
 * @return array
 */
function getRegionSpecific(array $projectData): array
{
    $regionSpecific = [];
    foreach ($projectData['regions'] as $regionName => $regionData) {
        $services = $regionData['services'];

        if (isset($services['key_value_store']['namespace'])) {
            $regionSpecific[$regionName]['SPRYKER_KEY_VALUE_STORE_NAMESPACE'] = $services['key_value_store']['namespace'];
        }
        if (isset($services['broker']['namespace'])) {
            $regionSpecific[$regionName]['SPRYKER_BROKER_NAMESPACE'] = $services['broker']['namespace'];
        }
        if (isset($services['session']['namespace'])) {
            $regionSpecific[$regionName]['SPRYKER_SESSION_BE_NAMESPACE'] = $services['session']['namespace'];
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
    $keyValueStoreData = $projectData['services']['key_value_store'];

    $connections = [];
    foreach ($projectData['regions'] as $regionName => $regionData) {
        $regionKeyValueStoreData = $keyValueStoreData;
        if (isset($regionData['services']['key_value_store'])) {
            $connections[$regionName] = $regionKeyValueStoreData = array_replace($regionKeyValueStoreData, $regionData['services']['key_value_store']);
        }
        foreach ($regionData['stores'] ?? [] as $storeName => $storeData) {
            if (!isset($storeData['services']['key_value_store'])) {
                continue;
            }
            $connections[$storeName] = array_replace($regionKeyValueStoreData, $storeData['services']['key_value_store']);
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
function getBrokerHosts(array $projectData, string $currentRegion): string
{
    $hosts = null;
    $storesData = $projectData['regions'][$currentRegion]['stores'] ?? null;

    if ($storesData !== null) {
        $hosts = getBrokerHostNamesMap($storesData);
    }

    if ($hosts === null) {
        $hosts = getBrokerHostNamesMap($projectData['regions']);
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
    $keys = array_keys($projectData['groups']);

    return $projectData['groups'][array_pop($keys)]['region'] ?? '';
}


