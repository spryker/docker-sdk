<?php

use DockerSDK\Model\SharedService;
use SharedServices\DataBuilder\BrokerDataBuilder;
use SharedServices\DataBuilder\RedisGuiDataBuilder;
use SharedServices\DataBuilder\SharedServiceDataBuilderInterface;
use SharedServices\SharedServicesFactory;

const DS = DIRECTORY_SEPARATOR;
define("APPLICATION_SOURCE_DIR", join(DS, [__DIR__, 'src']));
include_once join(DS, [__DIR__, 'vendor', 'autoload.php']);

$sharedServicesFactory = new SharedServicesFactory();
$sharedServicesConfig = $sharedServicesFactory->getConfig();
$sharedServicesFactory->getEloquentInitializer()->init();

// get all shared services, who has projects in relation

$sharedServices = SharedService::whereHas('projects')->get();

$result = [];

/** @var SharedServiceDataBuilderInterface[] $dataBuilders */
$dataBuilders = [
    new BrokerDataBuilder(),
    new RedisGuiDataBuilder(),
];

/** @var SharedService $sharedService */
foreach ($sharedServices as $sharedService) {
    $result[$sharedService->name] = [
        'engine' => $sharedService->engine,
        'version' => $sharedService->version,
    ];

    $data = [];
    $projects = $sharedService->projects()->withPivot('data')->get();

    foreach ($projects as $project) {
        $projectData = json_decode($project->pivot->data, true);

        if ($projectData == null) {
            continue;
        }

        $data = array_merge_recursive($data, $projectData);
    }

    if ($data == []) {
        $data = null;
    }


    foreach ($dataBuilders as $dataBuilder) {
        if ($dataBuilder->getSharedServiceName() !== $sharedService->name) {
            continue;
        }

        $data = $dataBuilder->build($data);
    }

    $result[$sharedService->name]['data'] = $data;
}

$networks = $sharedServicesConfig->getDockerSdkNetworkList();
$sharedServices = $result;
$projectName = $sharedServicesConfig->getDockerSdkProjectName();

$data = [
    'networks' => $networks,
    'sharedServices' => $sharedServices,
    'projectName' => $projectName,
];


$twig = $sharedServicesFactory->getTwig();

file_put_contents(
    $sharedServicesConfig->getDeploymentPath() . DS . 'shared-services.docker-compose.yml',
    $twig->render('docker-compose/shared-services.docker-compose.yml.twig', $data)
);

//var_dump($result);die();
