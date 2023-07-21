variable DEPLOYMENT_PATH { default = "" }
variable SPRYKER_PROJECT_NAME { default = "" }
variable SPRYKER_DOCKER_PREFIX { default = "" }
variable SPRYKER_DOCKER_TAG { default = "" }
variable SECRETS_FILE_PATH { default = "" }
variable SPRYKER_SDK_REVISION { default = "" }
variable SPRYKER_PLATFORM_IMAGE { default = "" }
variable SPRYKER_FRONTEND_IMAGE { default = "" }
variable SPRYKER_LOG_DIRECTORY { default = "" }
variable SPRYKER_PIPELINE { default = "" }
variable APPLICATION_ENV { default = "" }
variable SPRYKER_COMPOSER_MODE { default = "" }
variable SPRYKER_COMPOSER_AUTOLOAD { default = "" }
variable SPRYKER_ASSETS_MODE { default = "" }
variable SPRYKER_DB_ENGINE { default = "" }
variable KNOWN_HOSTS { default = "" }
variable SPRYKER_BUILD_HASH { default = "" }
variable SPRYKER_BUILD_STAMP { default = "" }
variable SPRYKER_NODE_IMAGE_VERSION { default = "" }
variable SPRYKER_NODE_IMAGE_DISTRO { default = "" }
variable SPRYKER_NPM_VERSION { default = "" }
variable USER_UID { default = "" }

variable AWS_ACCOUNT_ID { default = "" }
variable AWS_REGION { default = "" }

variable SPRYKER_BUILD_SSH { default = "" }
variable TARGET_TAG { default = "" }

target "_common" {
    dockerfile = "${DEPLOYMENT_PATH}/images/{{ folder }}/Dockerfile"
    context = "."
    labels = {
        "spryker.revision" = "${SPRYKER_BUILD_HASH}"
        "spryker.sdk.revision" = "${SPRYKER_SDK_REVISION}"
        "spryker.project" = "${SPRYKER_DOCKER_PREFIX}"
    }
    args = {
        DEPLOYMENT_PATH = "${DEPLOYMENT_PATH}"
        SPRYKER_PLATFORM_IMAGE = "${SPRYKER_PLATFORM_IMAGE}"
        SPRYKER_FRONTEND_IMAGE = "${SPRYKER_FRONTEND_IMAGE}"
        SPRYKER_LOG_DIRECTORY = "${SPRYKER_LOG_DIRECTORY}"
        SPRYKER_PIPELINE = "${SPRYKER_PIPELINE}"
        APPLICATION_ENV = "${APPLICATION_ENV}"
        SPRYKER_COMPOSER_MODE = "${SPRYKER_COMPOSER_MODE}"
        SPRYKER_COMPOSER_AUTOLOAD = "${SPRYKER_COMPOSER_AUTOLOAD}"
        SPRYKER_ASSETS_MODE = "${SPRYKER_ASSETS_MODE}"
        SPRYKER_DB_ENGINE = "${SPRYKER_DB_ENGINE}"
        KNOWN_HOSTS = "${KNOWN_HOSTS}"
        SPRYKER_BUILD_HASH = "${SPRYKER_BUILD_HASH}"
        SPRYKER_BUILD_STAMP = "${SPRYKER_BUILD_STAMP}"
        SPRYKER_NODE_IMAGE_VERSION = "${SPRYKER_NODE_IMAGE_VERSION}"
        SPRYKER_NODE_IMAGE_DISTRO = "${SPRYKER_NODE_IMAGE_DISTRO}"
        SPRYKER_NPM_VERSION = "${SPRYKER_NPM_VERSION}"
        USER_UID = "${USER_UID}"
    }
    secret = ["type=file,id=secrets-env,src=${SECRETS_FILE_PATH}"]
    ssh = ["${SPRYKER_BUILD_SSH}"]
}
