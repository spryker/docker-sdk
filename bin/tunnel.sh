#!/bin/bash

# Spryker PaaS Tunneling Script
# A standalone script for creating AWS SSM tunnels to Spryker PaaS services
# Based on spryker/docker-sdk PR #499

set -e

# shellcheck disable=SC2155

# Colors and constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
INFO="${BLUE}"
WARN="${YELLOW}"

# Script configuration
SCRIPT_NAME="Spryker PaaS Tunneling Script"
VERSION="0.0.1"
TRUE=0
FALSE=1

# Print functions
print_info() {
    echo -e "${INFO}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${WARN}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_log() {
    echo -e "${NC}$1"
}

# Help function
show_help() {
    cat << EOF
$SCRIPT_NAME v$VERSION

A standalone script for creating AWS SSM tunnels to Spryker PaaS services.
Based on spryker/docker-sdk PR #499.

REQUIREMENTS:
- AWS CLI installed and configured
- AWS Session Manager plugin for AWS CLI
- Valid AWS credentials with access to the Spryker environment

USAGE:
    $0 [auth|login]                      Configure AWS SSO authentication
    $0 environments                      List all Spryker environments
    $0 service-details --environment=ENV [services...]
    $0 create-tunnel --environment=ENV [services...]
    $0 close-tunnel [services...]
    $0 tunnels
    $0 profiles                          List available AWS profiles
    $0 set-profile PROFILE_NAME          Set AWS profile

COMMANDS:
    auth, login                          Configure AWS SSO and set profile
    environments                         List all Spryker environments
    service-details --environment=ENV   Show service connection details
    create-tunnel --environment=ENV     Create SSM tunnels to services
    close-tunnel                        Close tunnels for specified services
    tunnels                             List all active SSM tunnels
    profiles                            List all configured AWS profiles
    set-profile PROFILE_NAME            Set AWS_PROFILE environment variable

SERVICES:
    database                            Main database
    database-ro-replica                 Read-only database replica (production only)
    storage                             Redis/Key-Value store
    search                              Elasticsearch
    scheduler                           Jenkins/Scheduler
    broker                              RabbitMQ

EXAMPLES:
    $0 auth
    $0 environments
    $0 service-details --environment=my-env database storage
    $0 create-tunnel --environment=my-env database storage
    $0 close-tunnel database
    $0 tunnels

EOF
}

# Check dependencies (based on original patch require statement)
check_dependencies() {
    local missing_deps=()

    for dep in aws jq tr nc awk shuf sed grep lsof; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "AWS CLI and Session Manager plugin are required for PaaS commands"
        exit 1
    fi
}

# Check AWS session credentials (based on original Paas::checkAwsSessionCredentials)
check_aws_session_credentials() {
    if [ -z "$AWS_PROFILE" ]; then
        print_warning "AWS_PROFILE environment variable is not set"
        print_info "Run '$0 auth' to configure AWS SSO and set profile"
        return ${FALSE}
    fi

    print_info "Using AWS Profile: ${GREEN}${AWS_PROFILE}${NC}"

    AWS_ACCOUNT=$(aws sts get-caller-identity --output text --no-cli-pager --query "Account" 2>/dev/null)

    local exitcode=$?
    if [ "${exitcode}" -ne "0" ] || [ -z "$AWS_ACCOUNT" ]; then
        print_error "AWS session credentials not valid for profile: $AWS_PROFILE"
        print_info "Try: aws sso login --profile $AWS_PROFILE"
        return ${FALSE}
    fi

    if ! [[ ${FUNCNAME[@]} =~ "get_environments_cache_file" ]]; then
        print_info "You are authenticated with AWS Account ${GREEN}${AWS_ACCOUNT}${NC}"
    fi

    return ${TRUE}
}

# Get environment region (based on original Paas::get-environment-region)
get_environment_region() {
    local ENVIRONMENT=$1

    get_environments_cache_file
    ENVIRONMENT_REGION=$(grep "${ENVIRONMENT}:" ${ENVIRONMENT_TMP_FILE} | cut -d ":" -f2)

    return ${TRUE}
}

# Verify environment exists (based on original Paas::verify-environment-exists)
verify_environment_exists() {
    get_environments_cache_file

    local ENVIRONMENT=$1

    ENVIRONMENT_RESULT=$(grep -Ec "^${ENVIRONMENT}:" ${ENVIRONMENT_TMP_FILE} 2>/dev/null || true)

    if [ "${ENVIRONMENT_RESULT}" -eq 0 ]; then
        print_error "Environment ${ENVIRONMENT} does not exist in AWS account ${AWS_ACCOUNT}"
        exit 1
    fi

    return ${TRUE}
}

# Get environments cache file (based on original Paas::getEnvironmentsCacheFile)
get_environments_cache_file() {
    ENVIRONMENT_TMP_FILE=/tmp/${AWS_ACCOUNT}_spryker_paas_environments.tmp
    if [ ! -f ${ENVIRONMENT_TMP_FILE} ]; then
        print_info "Creating environments cache file"
        create_environments_cache_file ${ENVIRONMENT_TMP_FILE}

        # execute environments command only if it is not the original calling function
        if ! [[ ${FUNCNAME[@]} =~ "cmd_environments" ]]; then
            cmd_environments
        fi
    fi

    return ${TRUE}
}

# Create cache file (based on original Paas::createEnvironmentsCacheFile)
create_environments_cache_file() {
    local ENVIRONMENT_TMP_FILE=$1
    touch ${ENVIRONMENT_TMP_FILE}

    return ${TRUE}
}

# Write environments cache file (based on original Paas::writeEnvironmentsCacheFile)
write_environments_cache_file() {
    # clear existing cache
    truncate -s 0 ${ENVIRONMENT_TMP_FILE}

    # generate environments cache
    for ENTITY in "${ENVIRONMENTS_AND_REGIONS[@]}"; do
        if [ -n "$ENTITY" ]; then
            # split ENTITY by AWS Region, and ECS Cluster Name (Environment Name)
            ENTITY_ENVIRONMENT_NAME=$(echo "${ENTITY}" | cut -d ',' -f2)
            ENTITY_REGION=$(echo "${ENTITY}" | cut -d ',' -f1)

            print_log "Found environment ${GREEN}${ENTITY_ENVIRONMENT_NAME}${NC} in AWS region ${GREEN}${ENTITY_REGION}${NC}"

            echo "${ENTITY_ENVIRONMENT_NAME}:${ENTITY_REGION}" >> ${ENVIRONMENT_TMP_FILE}
        fi
    done

    # write environments to tmp file (cache file)
    print_info "Environments cache file ${ENVIRONMENT_TMP_FILE}"

    return ${TRUE}
}

# Discover random EC2 jump instance (based on original Paas::discoverRandomEc2JumpInstance)
discover_random_ec2_jump_instance() {
    local ENVIRONMENT=$1

    # get environment region
    get_environment_region "${ENVIRONMENT}"

    print_log "Selecting random EC2 instance jump host within environment ${GREEN}${ENVIRONMENT}${NC}"

    EC2_INSTANCE_ID=$(aws ec2 describe-instances --region ${ENVIRONMENT_REGION} --filters "Name=tag:Name,Values=*${ENVIRONMENT}-*" 'Name=instance-state-name,Values=running' --output text --no-cli-pager --query "Reservations[*].Instances[*].[InstanceId]" | shuf -n 1 || true)

    if [ "${EC2_INSTANCE_ID}" == "None" ] || [ "${EC2_INSTANCE_ID}" == "" ]; then
        print_error "Could not find EC2 instance"
        exit 1
    else
        print_log "Selected EC2 instance ${GREEN}${EC2_INSTANCE_ID}${NC}"
        return ${TRUE}
    fi
}

# Create search string (based on original Paas::create-search-string)
create_search_string() {
    local SEARCH_STRING=""
    for SEARCH_PATTERN in ${SEARCH_PATTERNS}; do
        if [[ -z "${SEARCH_STRING}" ]]; then
            SEARCH_STRING+="/${ENVIRONMENT}/codebuild/base_task_definition/${SEARCH_PATTERN}"
        else
            SEARCH_STRING+=" /${ENVIRONMENT}/codebuild/base_task_definition/${SEARCH_PATTERN}"
        fi
    done

    SEARCH_STRING_RESULT=${SEARCH_STRING}

    return ${TRUE}
}

# Get open port (based on original Paas::get-open-port)
get_open_port() {
    local SERVICE=$1

    case "${SERVICE}" in
        'database')
            START=5000
            END=5009
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                check_open_port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return ${TRUE}
            ;;
        'database-ro-replica')
            START=5010
            END=5019
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                check_open_port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return ${TRUE}
            ;;
        'storage')
            START=5020
            END=5029
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                check_open_port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return ${TRUE}
            ;;
        'search')
            START=5030
            END=5039
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                check_open_port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return ${TRUE}
            ;;
        'scheduler')
            START=5040
            END=5049
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                check_open_port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return ${TRUE}
            ;;
        'broker')
            START=5050
            END=5059
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                check_open_port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return ${TRUE}
            ;;
        *)
            echo "Unknown service ${SERVICE}"
            ;;
    esac

    return ${TRUE}
}

# Check if port is open (based on original Paas::check-open-port)
check_open_port() {
    local port=$1

    if ( nc -z localhost ${port} &>/dev/null ); then
        echo "Port ${port} is Busy. Trying the next available port."
    else
        echo "Port ${port} is Free"
        TUNNEL_LOCAL_PORT=${port}
    fi

    return ${TRUE}
}

# Close busy port (based on original Paas::close-busy-port)
close_busy_port() {
    local port=$1

    if ( nc -z localhost ${port} &>/dev/null ); then
        echo "Closing port ${port}"
        lsof -i tcp:${port} | awk 'NR!=1 {print $2}' | xargs kill
    fi

    return ${TRUE}
}

# Check if read replica exists (based on original Paas::check-read-replica-exists)
check_read_replica_exists() {
    SPRYKER_DB_RO_REPLICA_DETAILS=$(aws rds describe-db-instances --region ${ENVIRONMENT_REGION} --db-instance-identifier "${ENVIRONMENT}"-ro-replica-0 --output text --no-cli-pager --query "DBInstances[*].Endpoint[].[Address,Port]" 2> /dev/null || true)
    if [ "${SPRYKER_DB_RO_REPLICA_DETAILS}" == "" ]; then
        SPRYKER_DB_RO_REPLICA_EXIST=${FALSE}
    else
        SPRYKER_DB_RO_REPLICA_EXIST=${TRUE}
    fi

    return ${TRUE}
}

# Configure AWS SSO authentication
cmd_auth() {
    print_info "Starting AWS SSO configuration..."
    echo

    if aws configure sso; then
        print_success "AWS SSO configuration completed"
        echo

        cmd_profiles
        echo

        print_info "Please select a profile to use:"
        read -p "Enter profile name: " selected_profile

        if [ -n "$selected_profile" ]; then
            if aws configure list-profiles | grep -q "^${selected_profile}$"; then
                cmd_set_profile "$selected_profile"
            else
                print_error "Profile '$selected_profile' not found"
                exit 1
            fi
        else
            print_warning "No profile selected. You can set one later with '$0 set-profile PROFILE_NAME'"
        fi
    else
        print_error "AWS SSO configuration failed"
        exit 1
    fi
}

# List available AWS profiles
cmd_profiles() {
    print_info "Available AWS profiles:"

    if command -v aws &> /dev/null; then
        local profiles
        profiles=$(aws configure list-profiles 2>/dev/null)

        if [ -n "$profiles" ]; then
            echo "$profiles" | while read -r profile; do
                if [ -n "$profile" ]; then
                    if [ "$profile" = "$AWS_PROFILE" ]; then
                        echo "  ${GREEN}* $profile${NC} (current)"
                    else
                        echo "    $profile"
                    fi
                fi
            done
        else
            print_warning "No AWS profiles found"
            print_info "Run '$0 auth' to configure AWS SSO authentication"
        fi
    else
        print_error "AWS CLI not found"
        exit 1
    fi
}

# Set AWS profile
cmd_set_profile() {
    local profile_name="$1"

    if [ -z "$profile_name" ]; then
        print_error "Profile name is required"
        print_info "Usage: $0 set-profile PROFILE_NAME"
        exit 1
    fi

    if ! aws configure list-profiles | grep -q "^${profile_name}$"; then
        print_error "Profile '$profile_name' not found"
        cmd_profiles
        exit 1
    fi

    export AWS_PROFILE="$profile_name"

    print_success "AWS_PROFILE set to: ${GREEN}${profile_name}${NC}"
    print_info "Add this to your shell profile to make it permanent:"
    print_info "  ${BLUE}export AWS_PROFILE=${profile_name}${NC}"

    print_info "Testing profile authentication..."
    if check_aws_session_credentials; then
        print_success "Profile authentication successful"

        if [ -n "$AWS_ACCOUNT" ]; then
            local cache_file="/tmp/${AWS_ACCOUNT}_spryker_paas_environments.tmp"
            if [ -f "$cache_file" ]; then
                rm -f "$cache_file"
                print_info "Cleared environment cache for new profile"
            fi
        fi
    else
        print_warning "Profile authentication failed. You may need to login:"
        print_info "  ${BLUE}aws sso login --profile ${profile_name}${NC}"
    fi
}

# Print environments (based on original Paas::environments)
cmd_environments() {
    # check for valid AWS Session
    if ! check_aws_session_credentials; then
        exit 1
    fi

    print_log "This operation is currently searching the AWS account for Paas environments (All AWS regions)"
    print_log ""

    # the below call is executed asynchronously
    # we lookup all the available regions in the aws account, and for each region, we look for any ecs clusters (environments)
    ENVIRONMENTS_AND_REGIONS=( $(for region in $(aws ec2 describe-regions --output text --no-cli-pager | cut -f4); do aws ecs list-clusters --region="${region}" --output text --no-cli-pager --query "clusterArns[*]" | sed 's/\t\t*/\n/g' | cut -d ':' -f4,6 | grep -v 'scheduler' | sed 's/:cluster\//,/' & done) )

    if [ ${#ENVIRONMENTS_AND_REGIONS[@]} -eq 0 ]; then
        print_error "Could not find any environments!"
        exit 1
    fi

    # write environments and their regions to a cache file
    get_environments_cache_file
    write_environments_cache_file

    return ${TRUE}
}

# Fetch service details (based on original Paas::service-details)
cmd_service_details() {
    # check for valid AWS Session
    if ! check_aws_session_credentials; then
        exit 1
    fi

   # check if environment is set
    local ENVIRONMENT=${FALSE}
    for arg in "${@}"; do
        case "${arg}" in
            --environment=*)
                ENVIRONMENT="${arg#*=}"

                verify_environment_exists ${ENVIRONMENT}
                ;;
        esac
    done

    # enforce environment flag
    if [ "${ENVIRONMENT}" == "${FALSE}" ]; then
        print_error "You need to specify an environment with --environment=ENVIRONMENT_NAME"
        exit 1
    fi

    # get environment region
    get_environment_region ${ENVIRONMENT}
    print_info "Target environment ${GREEN}${ENVIRONMENT}${NC} AWS region ${GREEN}${ENVIRONMENT_REGION}${NC}"

    # database, storage, search, scheduler, broker
    for arg in "${@}"; do
        case "${arg}" in
            'database')
                print_info "Fetching ${GREEN}${arg}${NC} details"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_DB"
                aws ssm --region ${ENVIRONMENT_REGION} get-parameters-by-path --path "/${ENVIRONMENT}/codebuild/base_task_definition/" --recursive --with-decryption --output json --no-cli-pager | jq -r --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            'database-ro-replica')
                # adding RO Replica if we find one. These details do not exist within the Parameter Store
                print_info "Fetching ${GREEN}${arg}${NC} details. Only for ${GREEN}PRODUCTION${NC} environments. Use the credentials for the ${GREEN}database${NC} to connect"

                check_read_replica_exists

                if [ "${SPRYKER_DB_RO_REPLICA_EXIST}" != "${FALSE}" ]; then
                    SPRYKER_DB_RO_REPLICA_DETAILS=$(aws rds describe-db-instances --region ${ENVIRONMENT_REGION} --db-instance-identifier "${ENVIRONMENT}"-ro-replica-0 --output text --no-cli-pager --query "DBInstances[*].Endpoint[].[Address,Port]" | sed 's/\t\t*/\n/g')
                    SPRYKER_DB_RO_REPLICA_HOST=$(head -1 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)
                    SPRYKER_DB_RO_REPLICA_PORT=$(head -2 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)

                    echo "SPRYKER_DB_RO_REPLICA_HOST=${SPRYKER_DB_RO_REPLICA_HOST}"
                    echo "SPRYKER_DB_RO_REPLICA_PORT=${SPRYKER_DB_RO_REPLICA_PORT}"
                else
                    echo "READ-REPLICA not found."
                fi
                ;;
            'storage')
                print_info "Fetching ${GREEN}${arg}${NC} details"

                # SSM parameters
                SEARCH_PATTERNS="SPRYKER_KEY_VALUE SPRYKER_SESSION"
                for SEARCH_PATTERN in $SEARCH_PATTERNS; do
                    aws ssm --region ${ENVIRONMENT_REGION} get-parameters-by-path --path "/${ENVIRONMENT}/codebuild/base_task_definition/" --recursive --with-decryption --output json --no-cli-pager | jq -r --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/';
                done
                ;;
            'search')
                print_info "Fetching ${GREEN}${arg}${NC} details"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_SEARCH"
                aws ssm --region ${ENVIRONMENT_REGION} get-parameters-by-path --path "/${ENVIRONMENT}/codebuild/base_task_definition/" --recursive --with-decryption --output json --no-cli-pager | jq -r --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            'scheduler')
                print_info "Fetching ${GREEN}${arg}${NC} details"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_SCHEDULER"
                aws ssm --region ${ENVIRONMENT_REGION} get-parameters-by-path --path "/${ENVIRONMENT}/codebuild/base_task_definition/" --recursive --with-decryption --output json --no-cli-pager | jq -r --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            'broker')
                print_info "Fetching ${GREEN}${arg}${NC} details"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_BROKER"
                aws ssm --region ${ENVIRONMENT_REGION} get-parameters-by-path --path "/${ENVIRONMENT}/codebuild/base_task_definition/" --recursive --with-decryption --output json --no-cli-pager | jq -r --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            *)
                # Skip unknown arguments (like --environment)
                ;;
        esac
    done

    return ${TRUE}
}

# Create SSM tunnel (based on original Paas::create-tunnel)
cmd_create_tunnel() {
    # check for valid AWS Session
    if ! check_aws_session_credentials; then
        exit 1
    fi

    # check if environment is set
    local ENVIRONMENT=${FALSE}
    for arg in "${@}"; do
        case "${arg}" in
            --environment=*)
                ENVIRONMENT="${arg#*=}"

                verify_environment_exists ${ENVIRONMENT}
                ;;
        esac
    done

    # enforce environment flag
    if [ "${ENVIRONMENT}" == "${FALSE}" ]; then
        print_error "You need to specify an environment with --environment=ENVIRONMENT_NAME"
        exit 1
    fi

    # get environment region
    get_environment_region ${ENVIRONMENT}
    print_info "Target environment ${GREEN}${ENVIRONMENT}${NC} AWS region ${GREEN}${ENVIRONMENT_REGION}${NC}"

    # fetch all Service Connection Parameters to save time
    print_log "Fetching service connection parameters"

    # SSM Service Connection Parameters
    # create array of search patterns
    SEARCH_PATTERNS="SPRYKER_DB_HOST SPRYKER_DB_PORT SPRYKER_KEY_VALUE_STORE_HOST SPRYKER_KEY_VALUE_STORE_PORT SPRYKER_SEARCH_HOST SPRYKER_SEARCH_PORT SPRYKER_SCHEDULER_HOST SPRYKER_SCHEDULER_PORT SPRYKER_BROKER_API_HOST SPRYKER_BROKER_API_PORT"

    # create SSM Service Connection Parameters string SERVICE_CONNECTION_PARAMETERS from SEARCH_PATTERNS array
    create_search_string

    # do SSM call and set service connection variables
    SERVICE_CONNECTION_PARAMETERS=( $(aws ssm get-parameters --region ${ENVIRONMENT_REGION} --names ${SEARCH_STRING_RESULT} --with-decryption --no-cli-pager | jq -r '.Parameters[] | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/') )
    for SERVICE_CONNECTION_PARAMETER in "${SERVICE_CONNECTION_PARAMETERS[@]}"; do
        declare ${SERVICE_CONNECTION_PARAMETER};
    done

    # fetch details for RDS RO REPLICA if it exists
    check_read_replica_exists

    if [ "${SPRYKER_DB_RO_REPLICA_EXIST}" != "${FALSE}" ]; then
        SPRYKER_DB_RO_REPLICA_DETAILS=$(aws rds describe-db-instances --region ${ENVIRONMENT_REGION} --db-instance-identifier "${ENVIRONMENT}"-ro-replica-0 --output text --no-cli-pager --query "DBInstances[*].Endpoint[].[Address,Port]" | sed 's/\t\t*/\n/g')
        SPRYKER_DB_RO_REPLICA_HOST=$(head -1 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)
        SPRYKER_DB_RO_REPLICA_PORT=$(head -2 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)
    fi

    # discover random EC2 jump instance
    discover_random_ec2_jump_instance "${ENVIRONMENT}"

    # database, storage, search, scheduler, broker
    MAX_WAIT=60
    for arg in "${@}"; do
        case "${arg}" in
            'database')
                print_info "Establishing tunnel to ${GREEN}${arg}${NC} service"

                get_open_port ${arg}

                # create tunnel
                aws ssm start-session --region ${ENVIRONMENT_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_DB_HOST}",portNumber="${SPRYKER_DB_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!

                # confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        print_error "Could not establish connection. See /tmp/spryker-tunnel-${arg}.log for more details."
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    print_log "Remote Endpoint: ${GREEN}${SPRYKER_DB_HOST}${NC} Remote Port: ${GREEN}${SPRYKER_DB_PORT}${NC} Local Endpoint: ${GREEN}localhost${NC} Local Port: ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'database-ro-replica')
                print_info "Establishing tunnel to ${GREEN}${arg} RO REPLICA${NC} service. Only for ${GREEN}PRODUCTION${NC} environments. Use the credentials for the ${GREEN}database${NC} to connect"

                # check if READ-REPLICA exists
                if [ "${SPRYKER_DB_RO_REPLICA_EXIST}" == "${FALSE}" ]; then
                    echo "READ-REPLICA not found."
                    continue
                fi

                get_open_port ${arg}

                # create tunnel
                aws ssm start-session --region ${ENVIRONMENT_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_DB_RO_REPLICA_HOST}",portNumber="${SPRYKER_DB_RO_REPLICA_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!

                # confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        print_error "Could not establish connection. See /tmp/spryker-tunnel-${arg}.log for more details."
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    print_log "Remote Endpoint: ${GREEN}${SPRYKER_DB_RO_REPLICA_HOST}${NC} Remote Port: ${GREEN}${SPRYKER_DB_RO_REPLICA_PORT}${NC} Local Endpoint: ${GREEN}localhost${NC} Local Port: ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'storage')
                print_info "Establishing tunnel to ${GREEN}${arg}${NC} service"

                get_open_port ${arg}

                # create tunnel
                aws ssm start-session --region ${ENVIRONMENT_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_KEY_VALUE_STORE_HOST}",portNumber="${SPRYKER_KEY_VALUE_STORE_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!

                # confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        print_error "Could not establish connection. See /tmp/spryker-tunnel-${arg}.log for more details."
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    print_log "Remote Endpoint: ${GREEN}${SPRYKER_KEY_VALUE_STORE_HOST}${NC} Remote Port: ${GREEN}${SPRYKER_KEY_VALUE_STORE_PORT}${NC} Local Endpoint: ${GREEN}localhost${NC} Local Port: ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'search')
                print_info "Establishing tunnel to ${GREEN}${arg}${NC} service"

                get_open_port ${arg}

                # create tunnel
                aws ssm start-session --region ${ENVIRONMENT_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_SEARCH_HOST}",portNumber="${SPRYKER_SEARCH_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!

                # confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        print_error "Could not establish connection. See /tmp/spryker-tunnel-${arg}.log for more details."
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    print_log "Remote Endpoint: ${GREEN}${SPRYKER_SEARCH_HOST}${NC} Remote Port: ${GREEN}${SPRYKER_SEARCH_PORT}${NC} Local Endpoint: ${GREEN}localhost${NC} Local Port: ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'scheduler')
                print_info "Establishing tunnel to ${GREEN}${arg}${NC} service"

                get_open_port ${arg}

                # create tunnel
                aws ssm start-session --region ${ENVIRONMENT_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_SCHEDULER_HOST}",portNumber="${SPRYKER_SCHEDULER_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!

                # confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        print_error "Could not establish connection. See /tmp/spryker-tunnel-${arg}.log for more details."
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    print_log "Remote Endpoint: ${GREEN}${SPRYKER_SCHEDULER_HOST}${NC} Remote Port: ${GREEN}${SPRYKER_SCHEDULER_PORT}${NC} Local Endpoint: ${GREEN}localhost${NC} Local Port: ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'broker')
                print_info "Establishing tunnel to ${GREEN}${arg}${NC} service"

                get_open_port ${arg}

                # creating tunnel
                aws ssm start-session --region ${ENVIRONMENT_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_BROKER_API_HOST}",portNumber="${SPRYKER_BROKER_API_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!

                # confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        print_error "Could not establish connection. See /tmp/spryker-tunnel-${arg}.log for more details."
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    print_info "Remote Endpoint: ${GREEN}${SPRYKER_BROKER_API_HOST}${NC} Remote Port: ${GREEN}${SPRYKER_BROKER_API_PORT}${NC} Local Endpoint: ${GREEN}localhost${NC} Local Port: ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            *)
                # Skip unknown arguments (like --environment)
                ;;
        esac
    done

    return ${TRUE}
}

# Close SSM tunnels (based on original Paas::close-tunnel)
cmd_close_tunnel() {
    # database, storage, search, scheduler, broker
    for arg in "${@}"; do
        case "${arg}" in
            'database')
                print_info "Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5000
                END=5009

                for (( port=${START}; port<=${END}; port++ ))
                do
                    close_busy_port ${port}
                done

                ;;
            'database-ro-replica')
                print_info "Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5010
                END=5019

                for (( port=${START}; port<=${END}; port++ ))
                do
                    close_busy_port ${port}
                done

                ;;
            'storage')
                print_info "Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5020
                END=5029

                for (( port=${START}; port<=${END}; port++ ))
                do
                    close_busy_port ${port}
                done

                ;;
            'search')
                print_info "Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5030
                END=5039

                for (( port=${START}; port<=${END}; port++ ))
                do
                    close_busy_port ${port}
                done

                ;;
            'scheduler')
                print_info "Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5040
                END=5049

                for (( port=${START}; port<=${END}; port++ ))
                do
                    close_busy_port ${port}
                done

                ;;
            'broker')
                print_info "Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5050
                END=5059

                for (( port=${START}; port<=${END}; port++ ))
                do
                    close_busy_port ${port}
                done

                ;;
            *)
                echo "Unknown service ${arg}"
                ;;
        esac
    done

    return ${TRUE}
}

# List tunnels (based on original Paas::tunnels)
cmd_tunnels() {
    ps aux |grep -E 'aws ssm start-session.*' |grep -vE "grep"
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    check_dependencies

    local command=$1
    shift

    case "$command" in
        auth|login)
            cmd_auth "$@"
            ;;
        environments)
            cmd_environments "$@"
            ;;
        service-details)
            cmd_service_details "$@"
            ;;
        create-tunnel)
            cmd_create_tunnel "$@"
            ;;
        close-tunnel)
            cmd_close_tunnel "$@"
            ;;
        tunnels)
            cmd_tunnels "$@"
            ;;
        profiles)
            cmd_profiles "$@"
            ;;
        set-profile)
            cmd_set_profile "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
