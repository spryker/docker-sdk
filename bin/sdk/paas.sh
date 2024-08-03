#!/bin/bash

# shellcheck disable=SC2155

require aws jq tr nc awk shuf sed grep


function Paas::checkAwsSessionCredentials() {
    aws sts get-caller-identity >/dev/null
    
    EXITCODE=$?
    if [ "$EXITCODE" -ne "0" ]; then
        Console::error "${WARN}AWS Session Credentials is not set.${NC}"
        exit 1
    else
        return "${TRUE}"
    fi
}

function Paas::checkAwsRegionIsSet() {
    if [[ -z "$AWS_REGION" ]]; then
        Console::error "${WARN}Shell Variable AWS_REGION is not set.${NC}"
        exit 1
    else
        return "${TRUE}"
    fi
}

function Paas::discoverRandomEc2JumpInstance() {
    local ENVIRONMENT=$1

    Console::info "${INFO}Selecting Random EC2 Instance Jump Host Within Environment${NC} ${GREEN}${ENVIRONMENT}${NC}"

    EC2_INSTANCE_ID=$(aws ec2 describe-instances --region $AWS_REGION --filters "Name=tag:Name,Values=*$ENVIRONMENT-ecs-autoscaled*" 'Name=instance-state-name,Values=running' --output text --no-cli-pager --query "Reservations[*].Instances[*].[InstanceId]" | shuf -n 1)

    if [ "$EC2_INSTANCE_ID" == "None" ]; then
        Console::error "${WARN}Could not find EC2 Instance. Perhaps you are trying to interface with the wrong environment?${NC}"
        exit 1
    else
        Console::info "${INFO}Selected EC2 Instance${NC} ${GREEN}${EC2_INSTANCE_ID}${NC}"
        return "${TRUE}"
    fi
}

# Print out environment names. One environment name per line
function Paas::environments() {
    # Check for valid AWS Session
    Paas::checkAwsSessionCredentials

    # Check for valid AWS_REGION
    Paas::checkAwsRegionIsSet

    # SSM parameters
    SEARCH_PATTERN="SPRYKER_PROJECT_NAME"
    ENVIRONMENTS=$(aws ssm --region $AWS_REGION get-parameters-by-path --path / --recursive --with-decryption --output json --no-cli-pager | jq -r '.Parameters[] | select(.Name | contains("'$SEARCH_PATTERN'")) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/' | awk -F"=" '{ print $NF }')

    Console::info "${INFO}${ENVIRONMENTS}${NC}"

    return "${TRUE}"
}

function Paas::service-details() {
    # Check for valid AWS Session
    Paas::checkAwsSessionCredentials

    # Check for valid AWS_REGION
    Paas::checkAwsRegionIsSet

   # Check if environment is set
    local ENVIRONMENT=${FALSE}
    for arg in "${@}"; do
        case "${arg}" in
            --environment=*)
                ENVIRONMENT="${arg#*=}"
                Console::info "${INFO}Environment${NC} ${GREEN}${ENVIRONMENT}${NC}"
                ;;
        esac
    done

    # Enforce environment flag
    if [ "${ENVIRONMENT}" == "${FALSE}" ]; then
        Console::error "${WARN}You need to specify an environment with --environment=ENVIRONMENT_NAME${NC}"
        exit 1
    fi

    # database, storage, search, scheduler, broker
    for arg in "${@}"; do
        case "${arg}" in
            'database')
                Console::info "${INFO}Fetching ${GREEN}${arg}${NC} ${INFO}details${NC}"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_DB"
                aws ssm --region $AWS_REGION get-parameters-by-path --path / --recursive --with-decryption --output json --no-cli-pager | jq -r --arg ENVIRONMENT "$ENVIRONMENT/" --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($ENVIRONMENT) and contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            'database-ro-replica')
                # Adding RO Replica if we find one. These details do not exist within the Parameter Store
                Console::info "${INFO}Fetching ${GREEN}${arg}${NC}${INFO} details. Only for ${GREEN}PRODUCTION${NC}${INFO} environments. Use the credentials for the ${GREEN}database${NC} ${INFO}to connect${NC}"

                Paas::check-read-replica-exists

                if [ "${SPRYKER_DB_RO_REPLICA_EXIST}" != "${FALSE}" ]; then
                    SPRYKER_DB_RO_REPLICA_DETAILS=$(aws rds describe-db-instances --region $AWS_REGION --db-instance-identifier "${ENVIRONMENT}"-ro-replica-0 --output text --no-cli-pager --query "DBInstances[*].Endpoint[].[Address,Port]" | sed 's/\t\t*/\n/g')
                    SPRYKER_DB_RO_REPLICA_HOST=$(head -1 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)
                    SPRYKER_DB_RO_REPLICA_PORT=$(head -2 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)

                    echo "SPRYKER_DB_RO_REPLICA_HOST=${SPRYKER_DB_RO_REPLICA_HOST}"
                    echo "SPRYKER_DB_RO_REPLICA_PORT=${SPRYKER_DB_RO_REPLICA_PORT}"
                else
                    echo "READ-REPLICA not found."
                fi
                ;;
            'storage')
                Console::info "${INFO}Fetching ${GREEN}${arg}${NC} ${INFO}details${NC}"
                
                # SSM parameters
                SEARCH_PATTERNS="SPRYKER_KEY_VALUE SPRYKER_SESSION"
                for SEARCH_PATTERN in $SEARCH_PATTERNS; do 
                    aws ssm --region $AWS_REGION get-parameters-by-path --path / --recursive --with-decryption --output json --no-cli-pager | jq -r --arg ENVIRONMENT "$ENVIRONMENT/" --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($ENVIRONMENT) and contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/';
                done
                ;;
            'search')
                Console::info "${INFO}Fetching ${GREEN}${arg}${NC} ${INFO}details${NC}"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_SEARCH"
                aws ssm --region $AWS_REGION get-parameters-by-path --path / --recursive --with-decryption --output json --no-cli-pager | jq -r --arg ENVIRONMENT "$ENVIRONMENT/" --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($ENVIRONMENT) and contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            'scheduler')
                Console::info "${INFO}Fetching ${GREEN}${arg}${NC} ${INFO}details${NC}"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_SCHEDULER"
                aws ssm --region $AWS_REGION get-parameters-by-path --path / --recursive --with-decryption --output json --no-cli-pager | jq -r --arg ENVIRONMENT "$ENVIRONMENT/" --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($ENVIRONMENT) and contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            'broker')
                Console::info "${INFO}Fetching ${GREEN}${arg}${NC} ${INFO}details${NC}"

                # SSM parameters
                SEARCH_PATTERN="SPRYKER_BROKER"
                aws ssm --region $AWS_REGION get-parameters-by-path --path / --recursive --with-decryption --output json --no-cli-pager | jq -r --arg ENVIRONMENT "$ENVIRONMENT/" --arg SEARCH_PATTERN "$SEARCH_PATTERN" '.Parameters[] | select(.Name | contains($ENVIRONMENT) and contains($SEARCH_PATTERN)) | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'
                ;;
            *)
                Console::verbose "\nUnknown service ${INFO}${arg}${WARN}."
                ;;
        esac
    done

    return "${TRUE}"
}

function Paas::create-tunnel() {
    # Check for valid AWS Session
    Paas::checkAwsSessionCredentials

    # Check for valid AWS_REGION
    Paas::checkAwsRegionIsSet

    # Check if environment is set
    local ENVIRONMENT=${FALSE}
    for arg in "${@}"; do
        case "${arg}" in
            --environment=*)
                ENVIRONMENT="${arg#*=}"
                Console::info "${INFO}Environment${NC} ${GREEN}${ENVIRONMENT}${NC}"
                ;;
        esac
    done

    # Enforce environment flag
    if [ "${ENVIRONMENT}" == "${FALSE}" ]; then
        Console::error "${WARN}You need to specify an environment with --environment=ENVIRONMENT_NAME${NC}"
        exit 1
    fi

    # Fetch all Service Connection Parameters
    # Fetching connection details for all services to save time
    Console::info "${INFO}Fetching Service Connection Parameters${NC}"
    # SSM Service Connection Parameters 
    SEARCH_PATTERNS="SPRYKER_DB_HOST SPRYKER_DB_PORT SPRYKER_KEY_VALUE_STORE_HOST SPRYKER_KEY_VALUE_STORE_PORT SPRYKER_SEARCH_HOST SPRYKER_SEARCH_PORT SPRYKER_SCHEDULER_HOST SPRYKER_SCHEDULER_PORT SPRYKER_BROKER_API_HOST SPRYKER_BROKER_API_PORT"
    # Create SSM Service Connection Parameters Search String
    Paas::create-search-string "${SEARCH_PATTERNS}"
    # Do SSM call and set service connection variables
    for SERVICE_CONNECTION_PARAMTER in $(aws ssm get-parameters --region ${AWS_REGION} --names ${SEARCH_STRING_RESULT}  --with-decryption  | jq -r '.Parameters[] | "\(.Name)=\(.Value)"' | sed 's/^.*SPRYKER/SPRYKER/'); do
        declare $SERVICE_CONNECTION_PARAMTER; 
    done

    # Fetch details for RDS RO REPLICA if it exists
    Paas::check-read-replica-exists

    if [ "${SPRYKER_DB_RO_REPLICA_EXIST}" != "${FALSE}" ]; then
        SPRYKER_DB_RO_REPLICA_DETAILS=$(aws rds describe-db-instances --region $AWS_REGION --db-instance-identifier "$ENVIRONMENT"-ro-replica-0 --output text --no-cli-pager --query "DBInstances[*].Endpoint[].[Address,Port]" | sed 's/\t\t*/\n/g')
        SPRYKER_DB_RO_REPLICA_HOST=$(head -1 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)
        SPRYKER_DB_RO_REPLICA_PORT=$(head -2 <<<"${SPRYKER_DB_RO_REPLICA_DETAILS}" | tail -1)
    fi

    # Discover random EC2 jump instance
    Paas::discoverRandomEc2JumpInstance "${ENVIRONMENT}"

    # database, storage, search, scheduler, broker
    MAX_WAIT=60
    for arg in "${@}"; do
        case "${arg}" in
            'database')
                Console::info "${INFO}Establishing tunnel to ${NC}${GREEN}${arg}${NC} ${INFO}service${NC}"

                Paas::get-open-port ${arg}

                # Create tunnel
                aws ssm start-session --region ${AWS_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_DB_HOST}",portNumber="${SPRYKER_DB_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!
                
                # Confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        Console::error "${WARN}Could not establish conection. See /tmp/spryker-tunnel-${arg}.log for more details.${NC}"
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    Console::info "${INFO}Remote Endpoint:${NC} ${GREEN}${SPRYKER_DB_HOST}${NC} ${INFO}Remote Port:${NC} ${GREEN}${SPRYKER_DB_PORT}${NC} ${INFO}Local Endpoint:${NC} ${GREEN}localhost${NC} ${INFO}Local Port:${NC} ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'database-ro-replica')
                Console::info "${INFO}Establishing tunnel to ${NC}${GREEN}${arg} RO REPLICA${NC} ${INFO}service. Only for ${GREEN}PRODUCTION${NC}${INFO} environments. Use the credentials for the ${GREEN}database${NC} ${INFO}to connect${NC}"

                # check if READ-REPLICA exists
                if [ "${SPRYKER_DB_RO_REPLICA_EXIST}" == "${FALSE}" ]; then
                    echo "READ-REPLICA not found."
                    continue
                fi

                Paas::get-open-port ${arg}

                # Create tunnel
                aws ssm start-session --region ${AWS_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_DB_RO_REPLICA_HOST}",portNumber="${SPRYKER_DB_RO_REPLICA_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!

                # Confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        Console::error "${WARN}Could not establish conection. See /tmp/spryker-tunnel-${arg}.log for more details.${NC}"
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    Console::info "${INFO}Remote Endpoint:${NC} ${GREEN}${SPRYKER_DB_RO_REPLICA_HOST}${NC} ${INFO}Remote Port:${NC} ${GREEN}${SPRYKER_DB_RO_REPLICA_PORT}${NC} ${INFO}Local Endpoint:${NC} ${GREEN}localhost${NC} ${INFO}Local Port:${NC} ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'storage')
                Console::info "${INFO}Establishing tunnel to ${NC}${GREEN}${arg}${NC} ${INFO}service${NC}"

                Paas::get-open-port ${arg}

                # Create tunnel
                aws ssm start-session --region ${AWS_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_KEY_VALUE_STORE_HOST}",portNumber="${SPRYKER_KEY_VALUE_STORE_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!
                
                # Confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        Console::error "${WARN}Could not establish conection. See /tmp/spryker-tunnel-${arg}.log for more details.${NC}"
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    Console::info "${INFO}Remote Endpoint:${NC} ${GREEN}${SPRYKER_KEY_VALUE_STORE_HOST}${NC} ${INFO}Remote Port:${NC} ${GREEN}${SPRYKER_KEY_VALUE_STORE_PORT}${NC} ${INFO}Local Endpoint:${NC} ${GREEN}localhost${NC} ${INFO}Local Port:${NC} ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi

                ;;
            'search')
                Console::info "${INFO}Establishing tunnel to ${NC}${GREEN}${arg}${NC} ${INFO}service${NC}"

                Paas::get-open-port ${arg}

                # Create tunnel
                aws ssm start-session --region ${AWS_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_SEARCH_HOST}",portNumber="${SPRYKER_SEARCH_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!
                
                # Confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        Console::error "${WARN}Could not establish conection. See /tmp/spryker-tunnel-${arg}.log for more details.${NC}"
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    Console::info "${INFO}Remote Endpoint:${NC} ${GREEN}${SPRYKER_SEARCH_HOST}${NC} ${INFO}Remote Port:${NC} ${GREEN}${SPRYKER_SEARCH_PORT}${NC} ${INFO}Local Endpoint:${NC} ${GREEN}localhost${NC} ${INFO}Local Port:${NC} ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi
                
                ;;
            'scheduler')
                Console::info "${INFO}Establishing tunnel to ${NC}${GREEN}${arg}${NC} ${INFO}service${NC}"

                Paas::get-open-port ${arg}

                # Create tunnel
                aws ssm start-session --region ${AWS_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_SCHEDULER_HOST}",portNumber="${SPRYKER_SCHEDULER_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!
                
                # Confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        Console::error "${WARN}Could not establish conection. See /tmp/spryker-tunnel-${arg}.log for more details.${NC}"
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    Console::info "${INFO}Remote Endpoint:${NC} ${GREEN}${SPRYKER_SCHEDULER_HOST}${NC} ${INFO}Remote Port:${NC} ${GREEN}${SPRYKER_SCHEDULER_PORT}${NC} ${INFO}Local Endpoint:${NC} ${GREEN}localhost${NC} ${INFO}Local Port:${NC} ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi
                
                ;;
            'broker')
                Console::info "${INFO}Establishing tunnel to ${NC}${GREEN}${arg}${NC} ${INFO}service${NC}"
                
                Paas::get-open-port ${arg}

                # Creating tunnel
                aws ssm start-session --region ${AWS_REGION} \
                --target ${EC2_INSTANCE_ID} \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters host="${SPRYKER_BROKER_API_HOST}",portNumber="${SPRYKER_BROKER_API_PORT}",localPortNumber="${TUNNEL_LOCAL_PORT}" > /tmp/spryker-tunnel-${arg}.log & pid=$!
                
                # Confirm tunnel has started
                TUNNEL_CREATE_ATTEMPT=0
                until grep "Waiting for connections" /tmp/spryker-tunnel-${arg}.log
                do
                    sleep 1

                    if [[ ${TUNNEL_CREATE_ATTEMPT} -eq ${MAX_WAIT}  ]]
                    then
                        Console::error "${WARN}Could not establish conection. See /tmp/spryker-tunnel-${arg}.log for more details.${NC}"
                        exit 1
                    fi
                    ((TUNNEL_CREATE_ATTEMPT++))
                done

                if [ "${pid}" != "${FALSE}" ]; then
                    Console::info "${INFO}Remote Endpoint:${NC} ${GREEN}${SPRYKER_BROKER_API_HOST}${NC} ${INFO}Remote Port:${NC} ${GREEN}${SPRYKER_BROKER_API_PORT}${NC} ${INFO}Local Endpoint:${NC} ${GREEN}localhost${NC} ${INFO}Local Port:${NC} ${GREEN}${TUNNEL_LOCAL_PORT}${NC}"
                fi
                
                ;;
            *)
                Console::verbose "\nUnknown service ${INFO}${arg}${WARN}."
                ;;
        esac
    done

    return "${TRUE}"
}

function Paas::close-tunnel() {
    # database, storage, search, scheduler, broker
    for arg in "${@}"; do
        case "${arg}" in
            'database')
                Console::info "${INFO}Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5000
                END=5009

                for (( port=${START}; port<=${END}; port++ ))
                do
                    Paas::close-busy-port ${port}
                done

                ;;
            'database-ro-replica')
                Console::info "${INFO}Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5010
                END=5019

                for (( port=${START}; port<=${END}; port++ ))
                do
                    Paas::close-busy-port ${port}
                done

                ;;
            'storage')
                Console::info "${INFO}Closing tunnel to service ${GREEN}${arg}${NC}"
                
                START=5020
                END=5029

                for (( port=${START}; port<=${END}; port++ ))
                do
                    Paas::close-busy-port ${port}
                done

                ;;
            'search')
                Console::info "${INFO}Closing tunnel to service ${GREEN}${arg}${NC}"
                
                START=5030
                END=5039

                for (( port=${START}; port<=${END}; port++ ))
                do
                    Paas::close-busy-port ${port}
                done

                ;;
            'scheduler')
                Console::info "${INFO}Closing tunnel to service ${GREEN}${arg}${NC}"
                
                START=5040
                END=5049

                for (( port=${START}; port<=${END}; port++ ))
                do
                    Paas::close-busy-port ${port}
                done

                ;;
            'broker')
                Console::info "${INFO}Closing tunnel to service ${GREEN}${arg}${NC}"

                START=5050
                END=5059

                for (( port=${START}; port<=${END}; port++ ))
                do
                    Paas::close-busy-port ${port}
                done

                ;;
            *)
                Console::verbose "\nUnknown service ${INFO}${arg}${WARN}."
                ;;
        esac
    done

    return "${TRUE}"
}

function Paas::tunnels() {
    ps aux |grep -E 'aws ssm start-session.*' |grep -vE "grep"
}

function Paas::create-search-string() {
    local SEARCH_PATTERNS=$1
    local SEARCH_STRING=""

    for SEARCH_PATTERN in ${SEARCH_PATTERNS}; do 
        if [[ -z "${SEARCH_STRING}" ]]; then
            SEARCH_STRING+="/${ENVIRONMENT}/codebuild/base_task_definition/${SEARCH_PATTERN}"
        else
            SEARCH_STRING+=" /${ENVIRONMENT}/codebuild/base_task_definition/${SEARCH_PATTERN}"
        fi
    done

    SEARCH_STRING_RESULT=${SEARCH_STRING}

    return "${TRUE}"
}

function Paas::get-open-port() {
    
    local SERVICE=$1

    # database, storage, search, scheduler, broker
    case "${SERVICE}" in
        'database')
            START=5000
            END=5009
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                Paas::check-open-port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return "${TRUE}"
            ;;
        'database-ro-replica')
            START=5010
            END=5019
            TUNNEL_LOCAL_PORT=${FALSE}
            
            for (( port=${START}; port<=${END}; port++ ))
            do
                Paas::check-open-port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return "${TRUE}"
            ;;
        'storage')
            START=5020
            END=5029
            TUNNEL_LOCAL_PORT=${FALSE}
            
            for (( port=${START}; port<=${END}; port++ ))
            do
                Paas::check-open-port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return "${TRUE}"
            ;;
        'search')
            START=5030
            END=5039
            TUNNEL_LOCAL_PORT=${FALSE}
            
            for (( port=${START}; port<=${END}; port++ ))
            do
                Paas::check-open-port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return "${TRUE}"
            ;;
        'scheduler')
            START=5040
            END=5049
            TUNNEL_LOCAL_PORT=${FALSE}

            for (( port=${START}; port<=${END}; port++ ))
            do
                Paas::check-open-port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return "${TRUE}"
            ;;
        'broker')
            START=5050
            END=5059
            TUNNEL_LOCAL_PORT=${FALSE}
            
            for (( port=${START}; port<=${END}; port++ ))
            do
                Paas::check-open-port ${port}
                if [ "${TUNNEL_LOCAL_PORT}" != "${FALSE}" ]; then
                    break
                fi
                if [ "${TUNNEL_LOCAL_PORT}" == "${FALSE}" ] && [ $port == $END ]; then
                    echo "No available port found. Close some tunnels with the close-tunnel command"
                    exit 1
                fi
            done

            return "${TRUE}"
            ;;
        *)
            Console::verbose "\nUnknown service ${INFO}${SERVICE}${WARN}."
            ;;
    esac

    return "${TRUE}"
}

function Paas::check-open-port() {
    local port=$1

    if ( nc -z localhost ${port} &>/dev/null ); then
        echo "Port ${port} is Busy. Trying the next available port."
    else
        echo "Port ${port} is Free"
        TUNNEL_LOCAL_PORT=${port}
    fi

    return "${TRUE}"
}

function Paas::close-busy-port() {
    local port=$1

    if ( nc -z localhost ${port} &>/dev/null ); then
        echo "Closing port ${port}"
        lsof -i tcp:${port} | awk 'NR!=1 {print $2}' | xargs kill
    fi

    return "${TRUE}"
}

function Paas::check-read-replica-exists() {
    SPRYKER_DB_RO_REPLICA_DETAILS=$(aws rds describe-db-instances --region $AWS_REGION --db-instance-identifier "${ENVIRONMENT}"-ro-replica-0 --output text --no-cli-pager --query "DBInstances[*].Endpoint[].[Address,Port]" 2> /dev/null || true)
    if [ "$SPRYKER_DB_RO_REPLICA_DETAILS" == "" ]; then
        SPRYKER_DB_RO_REPLICA_EXIST=${FALSE}
    fi

    return "${TRUE}"
}