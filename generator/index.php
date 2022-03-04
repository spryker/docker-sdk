<?php

use DeployFileGenerator\DeployFileGeneratorFactory;
use DeployFileGenerator\Transfer\DeployFileTransfer;
use Spatie\Url\Url;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Yaml\Parser;
use Twig\Environment;
use Twig\Loader\ChainLoader;
use Twig\Loader\FilesystemLoader;
use Twig\TwigFilter;

define('DS', DIRECTORY_SEPARATOR);
define('APPLICATION_SOURCE_DIR', __DIR__ . DS . 'src');
include_once __DIR__ . DS . 'vendor' . DS . 'autoload.php';

$deploymentDir = '/data/deployment';
$projectYaml = buildProjectYaml($deploymentDir . '/project.yml');

if ($projectYaml == '') {
    exit(1);
}

$defaultDeploymentDir = getenv('SPRYKER_DOCKER_SDK_DEPLOYMENT_DIR') ?: './';
$platform = getenv('SPRYKER_DOCKER_SDK_PLATFORM') ?: 'linux'; // Possible values: linux windows macos

$loaders = new ChainLoader([
    new FilesystemLoader(APPLICATION_SOURCE_DIR . DS . 'templates'),
    new FilesystemLoader($deploymentDir),
]);
$twig = new Environment($loaders);
$nginxVarEncoder = new class() {
    public function encode($value)
    {
        return str_replace([' ', '"', '{', '}'], ['\ ', '\"', '\{', '\}'], (string)$value);
    }
};
$tfVarEncoder = new class() {
    public function encode($value)
    {
        return json_encode((string)$value, JSON_UNESCAPED_SLASHES);
    }
};
$envVarEncoder = new class() {
    private $isActive = false;

    public function encode($value)
    {
        if ($this->isActive) {
            return json_encode((string)$value, JSON_UNESCAPED_SLASHES);
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
$twig->addFilter(new TwigFilter('tf_var', [$tfVarEncoder, 'encode'], ['is_safe' => ['all']]));
$twig->addFilter(new TwigFilter('env_var', [$envVarEncoder, 'encode'], ['is_safe' => ['all']]));
$twig->addFilter(new TwigFilter('nginx_var', [$nginxVarEncoder, 'encode'], ['is_safe' => ['all']]));
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
$projectData['_syncIgnore'] = buildSyncIgnore($deploymentDir);
$projectData['_syncSessionName'] = preg_replace('/[^-a-zA-Z0-9]/', '-', $projectData['namespace'] . '-' . $projectData['tag'] . '-codebase');
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
$projectData['secrets'] = buildSecrets($deploymentDir);
$projectData = buildDefaultCredentials($projectData);

// TODO Make it optional in next major
// Making webdriver as required service for BC reasons
if (empty($projectData['services']['webdriver'])) {
    $projectData['services']['webdriver'] = [
        'engine' => 'phantomjs',
    ];
}

$projectData['_dashboardEndpoint'] = '';
if (!empty($projectData['services']['dashboard'])) {
    $projectData['services']['dashboard']['endpoints'] = $projectData['services']['dashboard']['endpoints'] ?? [
            'localhost' => []
        ];
    reset($projectData['services']['dashboard']['endpoints']);
    $projectData['_dashboardEndpoint'] = sprintf(
        '%s://%s',
        getCurrentScheme($projectData),
        key($projectData['services']['dashboard']['endpoints'])
    );
}

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

const YVES_APP = 'yves';
const ZED_APP = 'zed';
const GLUE_APP = 'glue';
const BACKOFFICE_APP = 'backoffice';
const BACKEND_GATEWAY_APP = 'backend-gateway';
const MERCHANT_PORTAL = 'merchant-portal';
const GLUE_STOREFRONT = 'glue-storefront';
const GLUE_BACKEND = 'glue-backend';

const ENTRY_POINTS = [
    BACKOFFICE_APP => 'Backoffice',
    BACKEND_GATEWAY_APP => 'BackendGateway',
    ZED_APP => 'Zed',
    YVES_APP => 'Yves',
    GLUE_APP => 'Glue',
    MERCHANT_PORTAL => 'MerchantPortal',
    GLUE_STOREFRONT => 'GlueStorefront',
    GLUE_BACKEND => 'GlueBackend',
];

foreach ($projectData['groups'] ?? [] as $groupName => $groupData) {
    foreach ($groupData['applications'] ?? [] as $applicationName => $applicationData) {
        foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {
            if ($endpointData === null) {
                $endpointData = [];
            }
            $entryPoint = $endpointData['entry-point'] ?? ENTRY_POINTS[$applicationData['application']] ?? str_replace('-', '', ucwords(strtolower($applicationName), '-'));
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

            if (array_key_exists('redirect', $endpointData)) {
                if ($application !== 'static') {
                    warn('`redirect` attribute is allowed for `static` application only');
                }

                $redirect = $endpointData['redirect'];

                if (!is_array($redirect)) {
                    $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['redirect']
                        = $redirect
                        = [
                        'url' => $redirect,
                    ];
                }

                $projectData['groups'][$groupName]['applications'][$applicationName]['endpoints'][$endpoint]['redirect']['url']
                    = ensureUrlScheme($redirect['url'], $projectData);
            }
        }
    }
}

foreach ($primal as $callbacks) {
    foreach ($callbacks as $callback) {
        $callback($projectData);
    }
}

$endpointMap = $projectData['_endpointMap'] = mapBackendEndpointsWithFallbackZed($projectData['_endpointMap']);

$projectData['_testing'] = [
    'defaultPort' => $defaultPort,
    'projectServices' => $projectData['services'],
    'endpointMap' => $endpointMap,
];

$projectData['_applications'] = [];
$frontend = [];
$environment = [
    'project' => $projectData['namespace'],
];

/**
 * @param array $endpointMap
 *
 * @return array
 */
function mapBackendEndpointsWithFallbackZed(array $endpointMap): array
{
    $zedApplicationsToCheck = [
        BACKOFFICE_APP,
        BACKEND_GATEWAY_APP,
    ];

    foreach ($zedApplicationsToCheck as $zedApplicationToCheck) {
        foreach ($endpointMap as $store => $storeEndpointMap) {
            if (array_key_exists($zedApplicationToCheck, $storeEndpointMap)) {
                continue;
            }
            $endpointMap[$store][$zedApplicationToCheck] = $storeEndpointMap[ZED_APP];
        }
    }

    return $endpointMap;
}

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

        $httpEndpoints = array_filter(
            $applicationData['endpoints'] ?? [],
            static function ($endpointData) {
                return ($endpointData['protocol'] ?? 'http') === 'http';
            }
        );

        if (!empty($httpEndpoints)) {
            $environment['applications'][] = [
                'name' => $applicationName,
                'endpoints' => array_map(
                    static function ($endpoint) use ($projectData) {
                        return sprintf('%s://%s', getCurrentScheme($projectData), $endpoint);
                    },
                    array_keys($httpEndpoints)
                )
            ];
        }

        foreach ($applicationData['endpoints'] ?? [] as $endpoint => $endpointData) {

            $host = strtok($endpoint, ':');
            $frontend[$host] = [
                'zone' => getFrontendZoneByDomainLevel($host),
                'type' => $applicationName,
                'internal' => (bool)($endpointData['internal'] ?? false),
            ];

            $authEngine = $endpointData['auth']['engine'] ?? 'none';
            if ($authEngine === 'basic') {

                if (!is_array($endpointData['auth']['users'])) {
                    throw new Exception('Basic auth demands user list to be applied.');
                }

                $authFolder = $deploymentDir . DS . 'context' . DS . 'nginx' . DS . 'auth';

                file_put_contents(
                    $authFolder . DS . $host . '.htpasswd',
                    generatePasswords($endpointData['auth']['users']),
                    FILE_APPEND
                );
            }

            $services = [];
            $isEndpointDataHasStore = array_key_exists('store', $endpointData);
            if ($isEndpointDataHasStore) {
                $services = array_replace_recursive(
                    $projectData['regions'][$groupData['region']]['stores'][$endpointData['store']]['services'],
                    $endpointData['services'] ?? []
                );
            }
            if ($isEndpointDataHasStore && $endpointData['store'] === ($projectData['docker']['testing']['store'] ?? '')) {
                $projectData['_testing']['storeName'] = $endpointData['store'];
                $projectData['_testing']['regionServices'] = array_merge($projectData['_testing']['services'] ?? [], $services);
                $projectData['_testing']['services'][$endpointData['store']][$applicationData['application']] = $services;
            }

            if ($applicationData['application'] === ZED_APP
                || $applicationData['application'] === BACKEND_GATEWAY_APP
                || $applicationData['application'] === BACKOFFICE_APP
                || $applicationData['application'] === MERCHANT_PORTAL
            ) {

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
        }
    }
}

if (!empty($projectData['services']['key_value_store']['replicas'])) {
    $replicas = $projectData['services']['key_value_store']['replicas']['number'] ?? 1;
    $projectData['services']['key_value_store']['replica-services'] = array_map(function ($index) {
        return 'replica' . $index;
    }, range(1, (int)$replicas));
    $projectData['services']['key_value_store']['options'] = json_encode([
        'replication' => 'predis',
    ], JSON_UNESCAPED_SLASHES);

    $sources = [
        'tcp://key_value_store?role=master', 'tcp://key_value_store'
    ];
    foreach ($projectData['services']['key_value_store']['replica-services'] as $replica) {
        $sources[] = 'tcp://key_value_store_' . $replica;
    }

    $projectData['services']['key_value_store']['sources'] = json_encode($sources, JSON_UNESCAPED_SLASHES);
}

foreach ($projectData['services'] ?? [] as $serviceName => $serviceData) {
    $httpEndpoints = array_filter(
        $serviceData['endpoints'] ?? [],
        static function ($endpointData) {
            return ($endpointData['protocol'] ?? 'http') === 'http';
        }
    );

    if (!empty($httpEndpoints)) {
        $environment['services'][] = [
            'name' => $serviceName,
            'endpoints' => array_map(
                static function ($endpoint) use ($projectData) {
                    return sprintf('%s://%s', getCurrentScheme($projectData), $endpoint);
                },
                array_keys($httpEndpoints)
            )
        ];
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
    $deploymentDir . DS . 'context' . DS . 'php' . DS . 'debug' . DS . 'etc' . DS . 'php' . DS . 'debug.conf.d' . DS . '99-from-deploy-yaml-php.ini',
    $twig->render('php/conf.d/99-from-deploy-yaml-php.ini.twig', $projectData)
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
    $deploymentDir . DS . 'terraform/secrets.sdk.auto.tfvars',
    $twig->render('terraform/secrets.sdk.auto.tfvars.twig', [
        'project' => $projectData,
    ])
);
file_put_contents(
    $deploymentDir . DS . 'terraform/frontend.json',
    json_encode($frontend, JSON_PRETTY_PRINT)
);
file_put_contents(
    $deploymentDir . DS . 'context/dashboard/environment/environment.json',
    json_encode($environment, JSON_PRETTY_PRINT)
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

$envVarEncoder->setIsActive(true);
file_put_contents(
    $deploymentDir . DS . 'env' . DS . 'cli' . DS . 'testing.env',
    $twig->render('env/cli/testing.env.twig', $projectData['_testing'])
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
        $ports[$port] = (int)$port;
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
 * @return string[]
 */
function buildSyncIgnore(string $deploymentDir): array
{
    $sourceFilePath = $deploymentDir . DS . '.dockersyncignore';

    if (!file_exists($sourceFilePath)) {
        return [];
    }

    $sourceContent = (string) file_get_contents($sourceFilePath);

    $rules = array();
    preg_match_all('/([^\n#]+)?.*$/im', $sourceContent, $rules);

    return array_map(static function ($element) {
        return addslashes(trim($element));
    }, array_filter($rules[1]));
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
        if ($key == 'distributed-tracing') {
            $newrelicEnvVariables = array_merge($newrelicEnvVariables, buildNewrelicDistributedTracing($projectData));

            continue;
        }

        $newrelicEnvVariables['NEWRELIC_' . strtoupper($key)] = $value;
    }
     return $newrelicEnvVariables;
}

/**
 * @param array $projectData
 *
 * @return string[]
 */
function buildNewrelicDistributedTracing(array $projectData): array
{
    $distributedTracingData = $projectData['docker']['newrelic']['distributed-tracing'] ?? [];

    return [
        'NEWRELIC_TRANSACTION_TRACER_ENABLED' => (int) $distributedTracingData['enabled'] ?? 0,
        'NEWRELIC_DISTRIBUTED_TRACING_ENABLED' => (int) $distributedTracingData['enabled'] ?? 0,
        'NEWRELIC_SPAN_EVENTS_ENABLED' => (int) $distributedTracingData['enabled'] ?? 0,
        'NEWRELIC_TRANSACTION_TRACER_THRESHOLD' => (int) $distributedTracingData['transaction-tracer-threshold'] ?? 0,
        'NEWRELIC_DISTRIBUTED_TRACING_EXCLUDE_NEWRELIC_HEADER' => (int) $distributedTracingData['exclude-newrelic-header'] ?? 0,
    ];
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

function warn($output)
{
    echo $output . PHP_EOL;
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
    return trim($projectData['composer']['autoload'] ?? ($projectData['_fileMode'] === 'baked' ? '--classmap-authoritative' : ''));
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

/**
 * @param string $host
 * @param int $level
 *
 * @return string
 */
function getFrontendZoneByDomainLevel(string $host, int $level = 2): string
{
    return implode('.', array_slice(explode('.', $host), -$level, $level, true));
}

/**
 * @param $projectData
 *
 * @return string
 */
function getCurrentScheme($projectData): string
{
    return ($projectData['docker']['ssl']['enabled'] ?? false) ? 'https' : 'http';
}

/**
 * @param string $urlString
 * @param array $projectData
 *
 * @return string
 */
function ensureUrlScheme(string $urlString, array $projectData): string
{
    $url = Url::fromString($urlString);

    if ($url->getScheme() === '') {
        return (string)$url->withScheme(getCurrentScheme($projectData));
    }

    return $urlString;
}

/**
 * @param string $deploymentDir
 *
 * @return string[]
 */
function buildSecrets(string $deploymentDir): array
{
    $data = [];
    $openSshKeys = generateOpenSshKeys($deploymentDir);

    $data['SPRYKER_OAUTH_KEY_PRIVATE'] = str_replace(PHP_EOL, '__LINE__', $openSshKeys['privateKey']);
    $data['SPRYKER_OAUTH_KEY_PUBLIC'] = str_replace(PHP_EOL, '__LINE__', $openSshKeys['publicKey']);
    $data['SPRYKER_OAUTH_ENCRYPTION_KEY'] = generateToken(48);
    $data['SPRYKER_OAUTH_CLIENT_IDENTIFIER'] = 'frontend';
    $data['SPRYKER_OAUTH_CLIENT_SECRET'] = generateToken(48);
    $data['SPRYKER_ZED_REQUEST_TOKEN'] = generateToken(80);

    return $data;
}

/**
 * @param string $deploymentDir
 *
 * @return string[]
 */
function generateOpenSshKeys(string $deploymentDir): array
{
    $sshDir = $deploymentDir . DS . 'context' . DS . 'ssh';
    if (!file_exists($sshDir)) {
        mkdir($sshDir);
    }

    $generatePrivateKeyCommandTemplate = 'openssl genrsa -out %s 2048 2>&1';
    $generatePublicKeyCommandTemplate = 'openssl rsa -in %s -pubout -out %s 2>&1';

    $privateKeyPath = $sshDir . DS .'private.key';
    $publicKeyPath = $sshDir . DS . 'public.key';

    exec(
        sprintf($generatePrivateKeyCommandTemplate, $privateKeyPath),
        $output,
        $returnCode
    );


    if ($returnCode > 0) {
        echo implode(PHP_EOL, $output);
        exit($returnCode);
    }

    exec(
        sprintf($generatePublicKeyCommandTemplate, $privateKeyPath, $publicKeyPath),
        $output,
        $returnCode
    );

    if ($returnCode > 0) {
        echo implode(PHP_EOL, $output);
        exit($returnCode);
    }

    verbose(implode(PHP_EOL, $output));

    $sshKeys =  [
        'privateKey' => file_get_contents($privateKeyPath),
        'publicKey' => file_get_contents($publicKeyPath),
    ];

    exec('rm -rf ' . $sshDir);

    return $sshKeys;
}

/**
 * @param int $tokenLength
 *
 * @return string
 */
function generateToken($tokenLength = 80): string
{
    $availableChars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $availableCharsLength = strlen($availableChars);
    $token = '';

    for($i = 0; $i < $tokenLength; $i++) {
        $randomChar = $availableChars[mt_rand(0, $availableCharsLength - 1)];
        $token .= $randomChar;
    }

    return $token;
}

/**
 * @param string $mainProjectYaml
 *
 * @return string
 */
function buildProjectYaml(string $mainProjectYaml): string
{
    $deployFileTransfer = new DeployFileTransfer();
    $deployFileTransfer = $deployFileTransfer->setInputFilePath($mainProjectYaml);
    $deployFileTransfer = $deployFileTransfer->setOutputFilePath($mainProjectYaml);

    $deployFileFactory = new DeployFileGeneratorFactory();
    $deployFileTransfer = $deployFileFactory->createDeployFileBuildProcessor()->process($deployFileTransfer);

    if ($deployFileTransfer->getValidationMessageBagTransfer()->getValidationResult() == []) {
        return $deployFileTransfer->getOutputFilePath();
    }

    $deployFileFactory->createDeployFileOutput()->renderValidationResult($deployFileTransfer);

    return '';
}

/**
 * @param array $projectData
 *
 * @return array
 */
function buildDefaultCredentials(array $projectData): array
{
    $projectData = buildDefaultCredentialsForDatabase($projectData);
    $projectData = buildDefaultCredentialsForBroker($projectData);

    return $projectData;
}

/**
 * @param array $projectData
 *
 * @return array
 */
function buildDefaultCredentialsForDatabase(array $projectData): array
{
    $projectData = buildDefaultRootCredentialsForDatabase($projectData);
    $projectData = buildDefaultRegionCredentialsForDatabase($projectData);

    return $projectData;
}

/**
 * @param array $projectData
 *
 * @return array
 */
function buildDefaultRootCredentialsForDatabase(array $projectData): array
{
    if (!isset($projectData['services']['database'])) {
        return $projectData;
    }

    $defaultDbServiceRootConfig = [
        'username' => 'root',
        'password' => 'secret',
    ];

    $dbServiceRootConfig = $projectData['services']['database']['root'] ?? [];

    $projectData['services']['database']['root'] = array_merge(
        $defaultDbServiceRootConfig,
        $dbServiceRootConfig
    );

    return $projectData;
}

/**
 * @param array $projectData
 *
 * @return array
 */
function buildDefaultRegionCredentialsForDatabase(array $projectData): array
{
    if (!isset($projectData['regions'])) {
        return $projectData;
    }

    $defaultDbRegionCredentials = [
        'username' => 'spryker',
        'password' => 'secret',
    ];

    foreach ($projectData['regions'] as $regionName => $regionConfig) {
        if (!isset($regionConfig['services']['database'])) {
            continue;
        }

        $regionDbConfig = $regionConfig['services']['database'];
        $regionDbConfig = array_merge($defaultDbRegionCredentials, $regionDbConfig);

        $projectData['regions'][$regionName]['services']['database'] = $regionDbConfig;
    }

    return $projectData;
}


/**
 * @param array $projectData
 *
 * @return array
 */
function buildDefaultCredentialsForBroker(array $projectData): array
{
    if (!isset($projectData['services']['broker'])) {
        return $projectData;
    }

    $defaultBrokerServiceCredentials = [
        'username' => 'spryker',
        'password' => 'secret',
    ];

    $brokerServiceCredentials = $projectData['services']['broker']['api'] ?? [];

    $projectData['services']['broker']['api'] = array_merge(
        $defaultBrokerServiceCredentials,
        $brokerServiceCredentials
    );

    return $projectData;
}
