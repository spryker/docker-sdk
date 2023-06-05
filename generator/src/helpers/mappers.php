<?php

/**
 * @param array $projectData
 * @param string $region
 *
 * @return array
 */
function getRegionEndpointMap(array $projectData, string $region = ''): array
{
    if ($region) {
        return $projectData['_endpointMap'][$region] ?? [];
    }

    return $projectData['_endpointMap'];
}

/**
 * @param array $servicesDataToMap
 *
 * @return array
 */
function getBrokerHostNamesMap(array $servicesDataToMap): array
{
    return array_map(function(array $servicesData) {
        return $servicesData['services']['broker']['namespace'] ?? '';
    }, $servicesDataToMap);
}
