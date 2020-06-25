<?php

use Symfony\Component\Yaml\Parser;
use Twig\Environment;
use Twig\Loader\ChainLoader;
use Twig\Loader\FilesystemLoader;
use Twig\TwigFilter;

define('DS', DIRECTORY_SEPARATOR);
define('APPLICATION_SOURCE_DIR', __DIR__ . DS . 'src');
include_once __DIR__ . DS . 'vendor' . DS . 'autoload.php';

$deploymentDir = '/data/deployment';
$projectYaml = $deploymentDir . '/project.yml';
$defaultDeploymentDir = getenv('SPRYKER_DOCKER_SDK_DEPLOYMENT_DIR') ?: './';
$platform = getenv('SPRYKER_DOCKER_SDK_PLATFORM') ?: 'linux'; // Possible values: linux windows macos

$loaders = new ChainLoader([
    new FilesystemLoader(APPLICATION_SOURCE_DIR . DS . 'templates'),
    new FilesystemLoader($deploymentDir),
]);
$twig = new Environment($loaders);
$envVarEncoder = new class() {
    private $isActive = false;

    public function encode($value)
    {
        if ($this->isActive) {
            return json_encode((string)$value);
        }

        return $value;
    }

    /**
     * @param bool $isActive
     */
    public function setIsActive(bool $isActive): void
    {
        $this->isActive = $isActive;
    }
};
$twig->addFilter(new TwigFilter('env_var', [$envVarEncoder, 'encode'], ['is_safe' => ['all']]));
$twig->addFilter(new TwigFilter('normalize_endpoint', static function ($string) {
    return str_replace(['.', ':'], ['dot', '_'], $string);
}, ['is_safe' => ['all']]));
$twig->addFilter(new TwigFilter('unique', static function ($array) {
    return array_unique($array);
}, ['is_safe' => ['all']]));
$yamlParser = new Parser();

$projectData = $yamlParser->parseFile($projectYaml);

$projectData['_knownHosts'] = buildKnownHosts($deploymentDir);
$projectData['_defaultDeploymentDir'] = $defaultDeploymentDir;
$projectData['tag'] = $projectData['tag'] ?? uniqid();
$projectData['_platform'] = $platform;
$mountMode = $projectData['_mountMode'] = retrieveMountMode($projectData, $platform);
$projectData['_isDevelopment'] = $mountMode !== 'baked';
$projectData['_fileMode'] = $mountMode === 'baked' ? 'baked' : 'mount';
$projectData['_ports'] = retrieveUniquePorts($projectData);
$defaultPort = $projectData['_defaultPort'] = getDefaultPort($projectData);
$hosts = $projectData['_hosts'] = retrieveHostNames($projectData);
$projectData['_phpExtensions'] = buildPhpExtensionList($projectData);
$projectData['_phpIni'] = buildPhpIniAdditionalConfig($projectData);
$projectData['_envs'] = array_merge(
    getAdditionalEnvVariables($projectData),
    buildNewrelicEnvVariables($projectData)
);
$projectData['storageData'] = retrieveStorageData($projectData);
$projectData['composer']['autoload'] = buildComposerAutoloadConfig($projectData);
$isAutoloadCacheEnabled = $projectData['_isAutoloadCacheEnabled'] = isAutoloadCacheEnabled($projectData);
$projectData['_requirementAnalyzerData'] = buildDataForRequirementAnalyzer($projectData);

verbose('Generating NGINX configuration... [DONE]');

@mkdir($deploymentDir . DS . 'env' . DS . 'cli', 0777, true);
@mkdir($deploymentDir . DS . 'terraform', 0777, true);
@mkdir($deploymentDir . DS . 'terraform' . DS . 'cli', 0777, true);

$primal = [];
$projectData['_entryPoints'] = [];
$projectData['_endpointMap'] = [];
$projectData['_storeSpecific'] = getStoreSpecific($projectData);
$debugPortIndex = 10000;
$projectData['_endpointDebugMap'] = [];

verbose('Generating ENV files... [DONE]');

foreach ($projectData['groups'] ?? [] as $groupName => $groupData) {
    foreach ($groupData['applications'] ?? [] as $applicationName => $applicationData) {
        foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {
            $entryPoint = $endpointData['entry-point'] ?? ucfirst(strtolower($applicationData['application']));
            $projectData['_entryPoints'][$entryPoint] = $entryPoint;
            $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['entry-point'] = $entryPoint;

            $application = $applicationData['application'];
            $store = $endpointData['store'] ?? null;
            $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['primal'] = false;
            while (!empty($projectData['_ports'][$debugPortIndex])) {
                $debugPortIndex++;
            }
            $projectData['_endpointDebugMap'][$endpoint] = $debugPortIndex++;

            if ($store) {
                # primal is true, or the first one
                $isPrimal = !empty($endpointData['primal']) || empty($primal[$store][$application]);
                if ($isPrimal) {
                    $primal[$store][$application] = function (&$projectData) use (
                        $groupName,
                        $applicationName,
                        $application,
                        $endpoint,
                        $store
                    ) {
                        $projectData['_endpointMap'][$store][$application] = $endpoint;
                        $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['primal'] = true;
                    };
                }
            }
        }
    }
}

foreach ($primal as $callbacks) {
    foreach ($callbacks as $callback) {
        $callback($projectData);
    }
}

$endpointMap = $projectData['_endpointMap'];
$projectData['_applications'] = [];
$frontend = [];
foreach ($projectData['groups'] ?? [] as $groupName => $groupData) {
    foreach ($groupData['applications'] ?? [] as $applicationName => $applicationData) {
        if ($applicationData['application'] !== 'static') {
            $projectData['_applications'][] = $applicationName;

            file_put_contents(
                $deploymentDir . DS . 'env' . DS . $applicationName . '.env',
                $twig->render(sprintf('env/application/%s.env.twig', $applicationData['application']), [
                    'applicationName' => $applicationName,
                    'applicationData' => $applicationData,
                    'project' => $projectData,
                    'regionName' => $groupData['region'],
                    'regionData' => $projectData['regions'][$groupData['region']],
                    'brokerConnections' => getBrokerConnections($projectData),
                ])
            );
        }

        foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {

            $host = strtok($endpoint, ':');
            $frontend[$host] = [
                'type' => $applicationName,
                'internal' => (bool)($endpointData['internal'] ?? false),
            ];

            $authEngine = $endpointData['auth']['engine'] ?? 'none';
            if ($authEngine === 'basic') {

                if (!is_array($endpointData['auth']['users'])) {
                    throw new Exception('Basic auth demands user list to be applied.');
                }

                file_put_contents(
                    $authFolder . DS . $host . '.htpasswd',
                    generatePasswords($endpointData['auth']['users']),
                    FILE_APPEND
                );
            }

            if ($applicationData['application'] === 'zed') {

                $services = array_replace_recursive(
                    $projectData['regions'][$groupData['region']]['stores'][$endpointData['store']]['services'],
                    $endpointData['services'] ?? []
                );

                $envVarEncoder->setIsActive(true);
                file_put_contents(
                    $deploymentDir . DS . 'env' . DS . 'cli' . DS . strtolower($endpointData['store']) . '.env',
                    $twig->render('env/cli/store.env.twig', [
                        'applicationName' => $applicationName,
                        'applicationData' => $applicationData,
                        'project' => $projectData,
                        'regionName' => $groupData['region'],
                        'regionData' => $projectData['regions'][$groupData['region']],
                        'brokerConnections' => getBrokerConnections($projectData),
                        'storeName' => $endpointData['store'],
                        'services' => $services,
                        'endpointMap' => $endpointMap,
                    ])
                );

                file_put_contents(
                    $deploymentDir . DS . 'terraform' . DS . 'cli' . DS . strtolower($endpointData['store']) . '.env',
                    $twig->render('terraform/store.env.twig', [
                        'applicationName' => $applicationName,
                        'applicationData' => $applicationData,
                        'project' => $projectData,
                        'regionName' => $groupData['region'],
                        'regionData' => $projectData['regions'][$groupData['region']],
                        'brokerConnections' => getBrokerConnections($projectData),
                        'storeName' => $endpointData['store'],
                        'services' => $services,
                        'endpointMap' => $endpointMap,
                    ])
                );
                $envVarEncoder->setIsActive(false);
            }

            if ($applicationData['application'] === 'yves') {

                $services = array_replace_recursive(
                    $projectData['regions'][$groupData['region']]['stores'][$endpointData['store']]['services'],
                    $endpointData['services'] ?? []
                );

                if ($endpointData['store'] === ($projectData['docker']['testing']['store'] ?? '')) {
                    $envVarEncoder->setIsActive(true);
                    file_put_contents(
                        $deploymentDir . DS . 'env' . DS . 'cli' . DS . 'testing.env',
                        $twig->render('env/cli/testing.env.twig', [
                            'applicationName' => $applicationName,
                            'applicationData' => $applicationData,
                            'project' => $projectData,
                            'host' => strtok($endpoint, ':'),
                            'port' => strtok($endpoint) ?: $defaultPort,
                            'regionName' => $groupData['region'],
                            'regionData' => $projectData['regions'][$groupData['region']],
                            'brokerConnections' => getBrokerConnections($projectData),
                            'storeName' => $endpointData['store'],
                            'services' => $services,
                            'endpointMap' => $endpointMap,
                        ])
                    );
                    $envVarEncoder->setIsActive(false);
                }
            }
        }
    }
}

file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'conf.d' . DS . 'frontend.default.conf.tmpl',
    $twig->render('nginx/conf.d/frontend.default.conf.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'conf.d' . DS . 'gateway.default.conf',
    $twig->render('nginx/conf.d/gateway.default.conf.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'stream.d' . DS . 'gateway.default.conf',
    $twig->render('nginx/stream.d/gateway.default.conf.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'conf.d' . DS . 'debug.default.conf',
    $twig->render('nginx/conf.d/debug.default.conf.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'entrypoint.sh',
    $twig->render('nginx/entrypoint.sh.twig', $projectData)
);

file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'php' . DS . 'conf.d' . DS . '99-from-deploy-yaml-php.ini',
    $twig->render('php/conf.d/99-from-deploy-yaml-php.ini.twig', $projectData)
);

file_put_contents(
    $deploymentDir . DS . 'env' . DS . 'testing.env',
    $twig->render('env/testing.env.twig', [
        'project' => $projectData,
    ])
);

file_put_contents(
    $deploymentDir . DS . 'env' . DS . 'swagger.env',
    $twig->render('env/swagger/swagger-ui.env.twig', [
        'project' => $projectData,
        'endpointMap' => $endpointMap,
    ])
);

$envVarEncoder->setIsActive(true);
file_put_contents(
    $deploymentDir . DS . 'terraform/environment.tf',
    $twig->render('terraform/environment.tf.twig', [
        'brokerConnections' => getCloudBrokerConnections($projectData),
        'project' => $projectData,
    ])
);
$envVarEncoder->setIsActive(false);
file_put_contents(
    $deploymentDir . DS . 'terraform/frontend.json',
    json_encode($frontend, JSON_PRETTY_PRINT)
);

file_put_contents(
    $deploymentDir . DS . 'images' . DS . 'common' . DS . 'application' . DS . 'Dockerfile',
    $twig->render('images' . DS . 'common' . DS . 'application' . DS . 'Dockerfile.twig', $projectData)
);
unlink($deploymentDir . DS . 'images' . DS . 'common' . DS . 'application' . DS . 'Dockerfile.twig');

file_put_contents(
    $deploymentDir . DS . 'docker-compose.yml',
    $twig->render('docker-compose.yml.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'docker-compose.test.yml',
    $twig->render('docker-compose.test.yml.twig', $projectData)
);

verbose('Generating scripts... [DONE]');

file_put_contents(
    $deploymentDir . DS . 'deploy',
    $twig->render('deploy.bash.twig', $projectData)
);

switch ($mountMode) {
    case 'docker-sync':
        file_put_contents(
            $deploymentDir . DS . 'docker-sync.yml',
            $twig->render('docker-sync.yml.twig', $projectData)
        );
        break;
}

verbose('Generating SSL certificates...');

$sslDir = $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'ssl';
exec(sprintf(
    'PFX_PASSWORD="%s" DESTINATION=%s DEPLOYMENT_DIR=%s ./openssl/generate.sh %s 2>&1',
    addslashes($projectData['docker']['ssl']['pfx-password'] ?? 'secret'),
    $sslDir,
    $deploymentDir,
    implode(' ', $hosts)
), $output, $returnCode);

if ($returnCode > 0) {
    exit($returnCode);
}

verbose(implode(PHP_EOL, $output));

// -------------------------
/**
 * @param array $projectData
 * @param string $platform
 *
 * @return string
 * @throws \Exception
 *
 */
function retrieveMountMode(array $projectData, string $platform): string
{
    $mountMode = 'baked';
    foreach ($projectData['docker']['mount'] ?? [] as $engine => $configuration) {
        if (in_array($platform, $configuration['platforms'] ?? [$platform], true)) {
            $mountMode = $engine;
            break;
        }
        $mountMode = '';
    }

    if ($mountMode === '') {
        throw new Exception(sprintf('Mount mode cannot be determined for `%s` platform', $platform));
    }

    return $mountMode;
}

/**
 * @param array $projectData
 *
 * @return int[]
 */
function retrieveUniquePorts(array $projectData)
{
    $ports = [];

    foreach (retrieveEndpoints($projectData) as $endpoint => $endpointData) {
        $port = explode(':', $endpoint)[1];
        $ports[$port] = $port;
    }

    if (array_key_exists(getDefaultPort($projectData), $ports) && !empty($projectData['docker']['ssl']['redirect'])) {
        $otherPort = getSSLRedirectPort($projectData);
        $ports[$otherPort] = $otherPort;
    }

    return $ports;
}

/**
 * @param array $projectData
 *
 * @return array[]
 * @throws \Exception
 *
 */
function retrieveEndpoints(array $projectData): array
{
    $defaultPort = getDefaultPort($projectData);

    $endpoints = [];

    foreach ($projectData['groups'] ?? [] as $groupName => $groupData) {
        foreach ($groupData['applications'] ?? [] as $applicationName => $applicationData) {
            foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {
                if (strpos($endpoint, ':') === false) {
                    $endpoint .= ':' . $defaultPort;
                }

                if (array_key_exists($endpoint, $endpoints)) {
                    throw new Exception(sprintf(
                        '`%s` endpoint is used for different applications. Please, make sure endpoints are unique',
                        $endpoint
                    ));
                }

                $endpointData['region'] = $groupData['region'];
                $endpointData['application'] = $applicationName;
                $endpoints[$endpoint] = $endpointData;
            }
        }
    }

    foreach ($projectData['services'] as $serviceName => $serviceData) {
        foreach ($serviceData['endpoints'] ?? [] as $endpoint => $endpointData) {
            if (strpos($endpoint, ':') === false) {
                $endpoint .= ':' . $defaultPort;
            }

            if (array_key_exists($endpoint, $endpoints)) {
                throw new Exception(sprintf(
                    '`%s` endpoint is used for different applications. Please, make sure endpoints are unique',
                    $endpoint
                ));
            }

            $endpointData['service'] = $serviceName;
            $endpoints[$endpoint] = $endpointData;
        }
    }

    return $endpoints;
}

/**
 * @param array $projectData
 *
 * @return string[]
 */
function retrieveHostNames(array $projectData): array
{
    $hosts = [];

    foreach (retrieveEndpoints($projectData) as $endpoint => $endpointData) {
        $host = strtok($endpoint, ':');
        $hosts[$host] = $host;
    }

    ksort($hosts);

    return $hosts;
}

/**
 * @param array $projectData
 *
 * @return int
 */
function getDefaultPort(array $projectData): int
{
    $sslEnabled = $projectData['docker']['ssl']['enabled'] ?? false;

    return $sslEnabled ? 443 : 80;
}

/**
 * @param array $projectData
 *
 * @return int
 */
function getSSLRedirectPort(array $projectData): int
{
    $sslEnabled = $projectData['docker']['ssl']['enabled'] ?? false;

    return $sslEnabled ? 80 : 443;
}

/**
 * @param array $projectData
 *
 * @return string
 */
function getBrokerConnections(array $projectData): string
{
    $brokerServiceData = $projectData['services']['broker'];

    $connections = [];
    foreach ($projectData['regions'] as $regionName => $regionData) {
        foreach ($regionData['stores'] ?? [] as $storeName => $storeData) {
            $localServiceData = array_replace($brokerServiceData, $storeData['services']['broker']);
            $connections[$storeName] = [
                'RABBITMQ_CONNECTION_NAME' => $storeName . '-connection',
                'RABBITMQ_HOST' => 'broker',
                'RABBITMQ_PORT' => $localServiceData['port'] ?? 5672,
                'RABBITMQ_USERNAME' => $localServiceData['api']['username'],
                'RABBITMQ_PASSWORD' => $localServiceData['api']['password'],
                'RABBITMQ_VIRTUAL_HOST' => $localServiceData['namespace'],
                'RABBITMQ_STORE_NAMES' => [$storeName], // check if connection is shared
            ];
        }
    }

    return json_encode($connections);
}

/**
 * @param array $projectData
 *
 * @return string
 */
function getCloudBrokerConnections(array $projectData): string
{
    $brokerServiceData = $projectData['services']['broker'];

    $connections = [];
    foreach ($projectData['regions'] as $regionName => $regionData) {
        foreach ($regionData['stores'] ?? [] as $storeName => $storeData) {
            $localServiceData = array_replace($brokerServiceData, $storeData['services']['broker']);
            $connections[$storeName] = [
                'RABBITMQ_VIRTUAL_HOST' => $localServiceData['namespace'],
            ];
        }
    }

    return json_encode($connections);
}

/**
 * @param array $projectData
 *
 * @return array
 */
function getStoreSpecific(array $projectData): array
{
    $storeSpecific = [];
    foreach ($projectData['regions'] as $regionName => $regionData) {
        foreach ($regionData['stores'] ?? [] as $storeName => $storeData) {

            $services = $storeData['services'];
            $storeSpecific[$storeName] = [
                'APPLICATION_STORE' => $storeName,
                'SPRYKER_SEARCH_NAMESPACE' => $services['search']['namespace'],
                'SPRYKER_KEY_VALUE_STORE_NAMESPACE' => $services['key_value_store']['namespace'],
                'SPRYKER_BROKER_NAMESPACE' => $services['broker']['namespace'],
                'SPRYKER_SESSION_BE_NAMESPACE' => $services['session']['namespace'] ?? 1,
                # TODO SESSION should not be used in CLI
            ];
        }
    }

    return $storeSpecific;
}

/**
 * @param string $deploymentDir
 *
 * @return string
 */
function buildKnownHosts(string $deploymentDir): string
{
    $knownHostsPath = $deploymentDir . DS . '.known_hosts';

    if (!file_exists($knownHostsPath)) {
        return '';
    }

    return implode(
        ' ',
        getKnownHosts($knownHostsPath)
    );
}

/**
 * @param string $knownHostsYamlPath
 *
 * @return array
 */
function getKnownHosts(string $knownHostsYamlPath): array
{
    $knownHosts = file_get_contents($knownHostsYamlPath);

    if (!$knownHosts) {
        return [];
    }

    return array_filter(
        preg_split('/[\s]+/', $knownHosts),
        function ($knownHost) {
            return $knownHost && isHostValid($knownHost);
        }
    );
}

/**
 * @param string $knownHost
 *
 * @return bool
 */
function isHostValid(string $knownHost): bool
{
    return isIp($knownHost) || isHost($knownHost);
}

/**
 * @param string $knownHost
 *
 * @return bool
 */
function isIp(string $knownHost): bool
{
    $validIpAddressPattern = "/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/";

    if (!preg_match($validIpAddressPattern, $knownHost)) {
        return false;
    }

    return true;
}

/**
 * @param string $knownHost
 *
 * @return bool
 */
function isHost(string $knownHost): bool
{
    $validHostnamePattern = "/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/";

    if (!preg_match($validHostnamePattern, $knownHost)) {
        return false;
    }

    $ipAddress = gethostbyname($knownHost);

    return $ipAddress !== $knownHost;
}

/**
 * @param array $projectData
 *
 * @return string[]
 */
function buildNewrelicEnvVariables(array $projectData): array
{
    if (!in_array('newrelic', $projectData['_phpExtensions'], true)) {
        return [];
    }

    $newrelicEnvVariables = [
        'NEWRELIC_ENABLED' => 1,
        'NEWRELIC_LICENSE' => '',
    ];

    if (empty($projectData['docker']['newrelic'])) {
        return $newrelicEnvVariables;
    }

    foreach ($projectData['docker']['newrelic'] as $key => $value) {
        $newrelicEnvVariables['NEWRELIC_' . strtoupper($key)] = $value;
    }

    return $newrelicEnvVariables;
}

/**
 * @param array $projectData
 *
 * @return array
 */
function buildPhpIniAdditionalConfig(array $projectData): array
{
    $additionalPhpConfiguration = $projectData['image']['php']['ini'] ?? [];

    if (!$additionalPhpConfiguration) {
        return $additionalPhpConfiguration;
    }

    $formattedAdditionalPhpConfiguration = [];

    foreach ($additionalPhpConfiguration as $key => $value) {
        $formattedAdditionalPhpConfiguration[] = sprintf(
            '%s = %s',
            $key,
            toString($value)
        );
    }

    return $formattedAdditionalPhpConfiguration;
}

/**
 * @param array $projectData
 *
 * @return array
 */
function buildPhpExtensionList(array $projectData): array
{
    return $projectData['image']['php']['enabled-extensions'] ?? [];
}

/**
 * @param array $projectData
 *
 * @return array
 */
function getAdditionalEnvVariables(array $projectData): array
{
    return $projectData['image']['environment'] ?? [];
}

/**
 * @param $value
 *
 * @return string
 */
function toString($value): string
{
    if (!is_bool($value)) {
        return (string)$value;
    }

    return $value ? 'true' : 'false';
}

/**
 * @param array $projectData
 *
 * @return array
 */
function retrieveStorageData(array $projectData): array
{
    $storageServices = retrieveStorageServices($projectData['services']);
    $regionsStorageHosts = retrieveRegionsStorageHosts($projectData['regions'], $storageServices);
    $groupsStorageHosts = retrieveGroupsStorageHosts($projectData['groups'], $storageServices);

    return [
        'hosts' => array_merge($regionsStorageHosts, $groupsStorageHosts),
        'services' => $storageServices,
    ];
}

function verbose($output)
{
    if (getenv('VERBOSE')) {
        echo $output . PHP_EOL;
    }
}

/**
 * @param array $services
 * @param string $engine
 *
 * @return string[]
 */
function retrieveStorageServices(array $services, string $engine = 'redis'): array
{
    $storageServices = [];
    foreach ($services as $serviceName => $serviceData) {
        if ($serviceData['engine'] === $engine) {
            $storageServices[] = $serviceName;
        }
    }

    return $storageServices;
}

/**
 * @param array $regions
 * @param string[] $storageServices
 * @param int $defaultPort
 *
 * @return array
 */
function retrieveRegionsStorageHosts(array $regions, array $storageServices, int $defaultPort = 6379): array
{
    $regionsStorageHosts = [];
    foreach ($regions ?? [] as $regionName => $regionData) {
        foreach ($regionData['stores'] as $storeData) {
            foreach ($storeData['services'] ?? [] as $serviceName => $serviceNamespace) {
                if (in_array($serviceName, $storageServices, true)) {
                    $regionsStorageHosts[] = sprintf('%s:%s:%s:%s', $serviceName, $serviceName, $defaultPort,
                        $serviceNamespace['namespace']);
                }
            }
        }
    }

    return $regionsStorageHosts;
}

/**
 * @param array $groups
 * @param string[] $storageServices
 * @param int $defaultPort
 *
 * @return array
 */
function retrieveGroupsStorageHosts(array $groups, array $storageServices, int $defaultPort = 6379): array
{
    $groupsStorageHosts = [];
    foreach ($groups ?? [] as $groupName => $groupData) {
        foreach ($groupData['applications'] as $application) {
            foreach ($application['endpoints'] as $endpoint => $endpointData) {
                foreach ($endpointData['services'] ?? [] as $serviceName => $serviceData) {
                    if (in_array($serviceName, $storageServices, true)) {
                        $groupsStorageHosts[] = sprintf('%s:%s:%s:%s', $serviceName, $serviceName, $defaultPort,
                            $serviceData['namespace']);
                    }
                }
            }
        }
    }

    return $groupsStorageHosts;
}

/**
 * @param array $projectData
 *
 * @return bool
 */
function isAutoloadCacheEnabled(array $projectData): bool
{
    if ($projectData['composer']['autoload'] !== '') {
        return false;
    }

    return $projectData['docker']['cache']['autoload']['enabled'] ?? false;
}

/**
 * @param array $projectData
 *
 * @return string
 */
function buildComposerAutoloadConfig(array $projectData): string
{
    return trim($projectData['composer']['autoload'] ?? '--optimize');
}

function buildDataForRequirementAnalyzer(array $projectData): array
{
    $hosts = $projectData['_hosts'];
    unset($hosts['localhost']);

    return [
        'hosts' => implode(' ', $hosts),
    ];
}

/**
 * @param int $length
 *
 * @return string
 * @throws \Exception
 */
function generateSalt(int $length = 16): string
{
    if (@is_readable('/dev/urandom')) {
        $f = fopen('/dev/urandom', 'rb');
        $salt = fread($f, $length);
        fclose($f);

        return $salt;
    }

    return random_bytes($length);
}

/**
 * @param $username
 * @param $password
 *
 * @return string
 * @throws \Exception
 */
function generateHtPassword(string $username, string $password): string
{
    $salt = generateSalt();

    return sprintf('%s:{SSHA}%s', $username, base64_encode(sha1($password . $salt, true) . $salt));
}

/**
 * @param array $users
 *
 * @return string
 */
function generatePasswords(array $users): string
{
    return implode(PHP_EOL, array_map(
        static function ($user) {

            if (empty($user['username'])) {
                throw new Exception('`username` is not set for basic auth.');
            }

            if (empty($user['password'])) {
                throw new Exception('`password` is not set for basic auth.');
            }

            return generateHtPassword($user['username'], $user['password']);
        },
        $users
    ));
}
