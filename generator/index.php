<?php

use Symfony\Component\Yaml\Parser;
use Twig\Environment;
use Twig\Loader\FilesystemLoader;

define('DS', DIRECTORY_SEPARATOR);
define('APPLICATION_SOURCE_DIR', __DIR__ . DS . 'src');
include_once __DIR__ . DS . 'vendor' . DS . 'autoload.php';

$deploymentDir = getenv('SPRYKER_DOCKER_SDK_DEPLOYMENT_DIR') ?: '/tmp';
$projectYaml = getenv('SPRYKER_DOCKER_SDK_PROJECT_YAML') ?: '';
$projectName = getenv('SPRYKER_DOCKER_SDK_PROJECT_NAME') ?: '';
$platform = getenv('SPRYKER_DOCKER_SDK_PLATFORM') ?: 'linux'; // Possible values: linux windows macos

$loader = new FilesystemLoader(APPLICATION_SOURCE_DIR . DS . 'templates');
$twig = new Environment($loader);
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
$twig->addFilter(new \Twig\TwigFilter('env_var', [$envVarEncoder, 'encode'], ['is_safe' => ['all']]));
$yamlParser = new Parser();

$projectData = $yamlParser->parseFile($projectYaml);
$projectData['_knownHosts'] = buildKnownHosts($deploymentDir);

$projectData['_projectName'] = $projectName;
$projectData['tag'] = $projectData['tag'] ?? uniqid();
$projectData['_platform'] = $platform;
$mountMode = $projectData['_mountMode'] = retrieveMountMode($projectData, $platform);
$projectData['_ports'] = retrieveUniquePorts($projectData);
$defaultPort = $projectData['_defaultPort'] = getDefaultPort($projectData);
$hosts = $projectData['_hosts'] = retrieveHostNames($projectData);
$blackfireConfig = $projectData['_blackfire'] = buildBlackfireConfiguration($projectData);

mkdir($deploymentDir . DS . 'env' . DS . 'cli', 0777, true);
mkdir($deploymentDir . DS . 'terraform', 0777, true);
mkdir($deploymentDir . DS . 'terraform' . DS . 'cli', 0777, true);
mkdir($deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'conf.d', 0777, true);
mkdir($authFolder = $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'auth', 0777, true);
mkdir($deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'stream.d', 0777, true);
mkdir($deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'frontend', 0777, true);

$primal = [];
foreach ($projectData['groups'] ?? [] as $groupName => $groupData) {
    foreach ($groupData['applications'] ?? [] as $applicationName => $applicationData) {
        foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {
            $entryPoint = $endpointData['entry-point'] ?? ucfirst(strtolower($applicationData['application']));
            $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['entry-point'] = $entryPoint;

            $application = $applicationData['application'];
            $store = $endpointData['store'] ?? null;
            $isPrimal = $store && (!empty($endpointData['primal']) || !array_key_exists($store, $primal));
            if ($isPrimal) {
                $primal[$store][$application] = function (&$projectData) use ($groupName, $applicationName, $application, $endpoint, $store) {
                    $projectData['_endpointMap'][$store][$application] = $endpoint;
                    $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['primal'] = true;
                };
            }
            $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['primal'] = false;
        }
    }
}

foreach ($primal as $callbacks) {
    foreach ($callbacks as $callback) {
        $callback($projectData);
    }
}

$endpointMap = $projectData['_endpointMap'];
$projectData['_storeSpecific']  = getStoreSpecific($projectData);
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
            ];

            $authEngine = $endpointData['auth']['engine'] ?? 'none';
            if ($authEngine === 'basic') {
                file_put_contents(
                    $authFolder . DS . $host . '.htpasswd',
                    generateHtPassword($endpointData['auth']['username'], $endpointData['auth']['password']),
                    FILE_APPEND
                );
            }

            if ($applicationData['application'] === 'zed') {

                $services = array_replace_recursive(
                    $projectData['regions'][$groupData['region']]['stores'][$endpointData['store']]['services'],
                    $endpointData['services'] ?? []
                );

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

                $envVarEncoder->setIsActive(true);
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
                }
            }
        }
    }
}

file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'conf.d' . DS . 'front-end.default.conf',
    $twig->render('nginx/conf.d/front-end.default.conf.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'stream.d' . DS . 'front-end.default.conf',
    $twig->render('nginx/stream.d/front-end.default.conf.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'conf.d' . DS . 'zed-rpc.default.conf',
    $twig->render('nginx/conf.d/zed-rpc.default.conf.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'frontend' . DS . 'default.conf.tmpl',
    $twig->render('nginx/frontend/default.conf.tmpl.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'frontend' . DS . 'entrypoint.sh',
    $twig->render('nginx/frontend/entrypoint.sh.twig', $projectData)
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
        'brokerConnections' => getBrokerConnections($projectData),
        'project' => $projectData,
    ])
);
$envVarEncoder->setIsActive(false);
file_put_contents(
    $deploymentDir . DS . 'terraform/frontend.json',
    json_encode($frontend, JSON_PRETTY_PRINT)
);

file_put_contents(
    $deploymentDir . DS . 'docker-compose.yml',
    $twig->render('docker-compose.yml.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'docker-compose.xdebug.yml',
    $twig->render('docker-compose.xdebug.yml.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'docker-compose.test.yml',
    $twig->render('docker-compose.test.yml.twig', $projectData)
);
file_put_contents(
    $deploymentDir . DS . 'docker-compose.test.xdebug.yml',
    $twig->render('docker-compose.test.xdebug.yml.twig', $projectData)
);
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

$sslDir = $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'ssl';
mkdir($sslDir);
echo shell_exec(sprintf(
    'PFX_PASSWORD="%s" DESTINATION=%s ./openssl/generate.sh %s',
    addslashes($projectData['docker']['ssl']['pfx-password'] ?? 'secret'),
    $sslDir,
    implode(' ', $hosts)
));

copy($sslDir . DS . 'ca.pfx', $deploymentDir . DS . 'spryker.pfx');

// -------------------------
/**
 * @param array $projectData
 * @param string $platform
 *
 * @throws \Exception
 *
 * @return string
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

    return $ports;
}

/**
 * @param array $projectData
 *
 * @throws \Exception
 *
 * @return array[]
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
//                'RABBITMQ_CONNECTION_NAME' => $storeName . '-connection',
//                'RABBITMQ_HOST' => 'broker',
//                'RABBITMQ_PORT' => $localServiceData['port'] ?? 5672,
//                'RABBITMQ_USERNAME' => $localServiceData['api']['username'],
//                'RABBITMQ_PASSWORD' => $localServiceData['api']['password'],
                'RABBITMQ_VIRTUAL_HOST' => $localServiceData['namespace'],
//                'RABBITMQ_STORE_NAMES' => [$storeName], // check if connection is shared
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
function getStoreSpecific(array $projectData): string
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
                'SPRYKER_SESSION_BE_NAMESPACE' => $services['session']['namespace'],
            ];
        }
    }

    return json_encode($storeSpecific);
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

    if ($ipAddress === $knownHost) {
        return false;
    }

    return true;
}

function buildBlackfireConfiguration(array $projectData): array
{
    if (!isset($projectData['docker']['blackfire'])) {
        return [];
    }

    $blackfireConfig = $projectData['docker']['blackfire'];

    if (!isBlackFireEnabled($blackfireConfig)) {
        return [];
    }

    validateBlackfireConfig($blackfireConfig);

    return $blackfireConfig;
}

function isBlackFireEnabled(array $blackfireConfig): bool
{
    return $blackfireConfig['enabled'] ?? false;
}

function validateBlackfireConfig(array $blackfireConfig): bool
{
    $missedParams = [];
    $requireParams = [
        'server-id',
        'server-token',
    ];

    foreach ($requireParams as $requireParam) {
        if (!isset($blackfireConfig[$requireParam])) {
            $missedParams[] = $requireParam;
        }
    }

    if (empty($missedParams)) {
        return true;
    }

    throw new Exception(
        'Blackfire configuration should contains next fields: ' . PHP_EOL . ' * '
        . implode(PHP_EOL . ' * ', $missedParams) . PHP_EOL
    );
}

function generateSalt($length = 16)
{
    if (@is_readable('/dev/urandom')) {
        $f = fopen('/dev/urandom', 'rb');
        $salt = fread($f, $length);
        fclose($f);

        return $salt;
    }

    return random_bytes($length);
}

function generateHtPassword($username, $password)
{
    $salt = generateSalt();

    return sprintf('%s:{SSHA}%s', $username, base64_encode(sha1($password . $salt, true) . $salt));
}
