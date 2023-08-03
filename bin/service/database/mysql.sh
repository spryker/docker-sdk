#!/bin/bash


function Database::checkConnection() {
    if ! Service::isServiceExist database; then
        return;
    fi

    local -i retriesFor=180
    local -i interval=2
    local counter=1

    while :; do
        [ "${counter}" -gt 0 ] && echo -en "\rWaiting for database connection [${counter}/${retriesFor}]..." || echo -en ""
        local status=$(Compose::exec "mysqladmin ping -h \${SPRYKER_DB_HOST} -u \${SPRYKER_DB_ROOT_USERNAME} -p\${SPRYKER_DB_ROOT_PASSWORD} --silent" "${DOCKER_COMPOSE_TTY_DISABLED}" | grep -c "mysqld is alive")
        [ "${status}" -eq 1 ] && echo -en "${CLEAR}\r" && break

        if [ $((counter % 5)) -eq 0 ]; then
            Compose::command restart database
        fi

        [ "${counter}" -ge "${retriesFor}" ] && echo -e "\r${WARN}Could not wait for database anymore.${NC}" && exit 1
        counter=$((counter + interval))
        sleep "${interval}"
    done
}


function Database::haveTables() {
    Database::checkConnection

    tableCount=$(
        Compose::exec <<'EOF'
        export VERBOSE=0
        export MYSQL_PWD="${SPRYKER_DB_ROOT_PASSWORD}"
        databases="$(echo ${SPRYKER_PAAS_SERVICES} | jq  '.databases')";
        if [ -z "${databases}" ] || [ "${databases}" == "[]" ]; then
            mysql \
                -h "${SPRYKER_DB_HOST}" \
                -u "${SPRYKER_DB_ROOT_USERNAME}" \
                -e "SELECT TABLE_NAME FROM information_schema.tables WHERE table_schema = \"${SPRYKER_DB_DATABASE}\"" \
                | wc -l \
                |  sed "s/^ *//" \
                | tr -d " \n\r" \
                || echo 0
        else
            echo ${databases} | jq -c '.[]' | while read line; do
                SPRYKER_DB_HOST=$(echo $line | jq -r .host);
                SPRYKER_DB_DATABASE=$(echo $line | jq -r .database);
                tablesCountPerDb=$(mysql \
                    -h "${SPRYKER_DB_HOST}" \
                    -u "${SPRYKER_DB_ROOT_USERNAME}" \
                    -e "SELECT TABLE_NAME FROM information_schema.tables WHERE table_schema = \"${SPRYKER_DB_DATABASE}\"" \
                    | wc -l \
                    |  sed "s/^ *//" \
                    | tr -d " \n\r" \
                    || echo 0)

                if [ "$tablesCountPerDb" == 0 ]; then
                    echo 0;
                    break
                fi

            done

            echo 1;
        fi
EOF
    )

    ( [ ! -z "${tableCount}" ] &&  [ "${tableCount}" -gt 0 ]) && return "${TRUE}" || return "${FALSE}"
}

function Database::init() {
      Database::checkConnection

      Compose::exec <<'EOF'
        export MYSQL_PWD="${SPRYKER_DB_ROOT_PASSWORD}";
        databases="$(echo ${SPRYKER_PAAS_SERVICES} | jq  '.databases')";

        if [ -z "${databases}" ] || [ "${databases}" == "[]" ]; then
            mysql \
                -h "${SPRYKER_DB_HOST}" \
                -u root \
                -e "CREATE DATABASE IF NOT EXISTS \`${SPRYKER_DB_DATABASE}\` CHARACTER SET \"${SPRYKER_DB_CHARACTER_SET}\" COLLATE \"${SPRYKER_DB_COLLATE}\"; GRANT ALL PRIVILEGES ON \`${SPRYKER_DB_DATABASE}\`.* TO \"${SPRYKER_DB_USERNAME}\"@\"%\" IDENTIFIED BY \"${SPRYKER_DB_PASSWORD}\" WITH GRANT OPTION;"
        else
            echo ${databases} | jq -c '.[]' | while read line; do
              SPRYKER_DB_HOST=$(echo $line | jq -r .host);
              SPRYKER_DB_USERNAME=$(echo $line | jq -r .username);
              SPRYKER_DB_PASSWORD=$(echo $line | jq -r .password);
              SPRYKER_DB_DATABASE=$(echo $line | jq -r .database);
              SPRYKER_DB_CHARACTER_SET=$(echo $line | jq -r .characterSet);
              SPRYKER_DB_COLLATE=$(echo $line | jq -r .collate);
              export MYSQL_PWD="${SPRYKER_DB_ROOT_PASSWORD}";
              mysql \
                -h "${SPRYKER_DB_HOST}" \
                -u root \
                -e "CREATE DATABASE IF NOT EXISTS \`${SPRYKER_DB_DATABASE}\` CHARACTER SET \"${SPRYKER_DB_CHARACTER_SET}\" COLLATE \"${SPRYKER_DB_COLLATE}\"; GRANT ALL PRIVILEGES ON \`${SPRYKER_DB_DATABASE}\`.* TO \"${SPRYKER_DB_USERNAME}\"@\"%\" IDENTIFIED BY \"${SPRYKER_DB_PASSWORD}\" WITH GRANT OPTION;"
            done
        fi
EOF
}
