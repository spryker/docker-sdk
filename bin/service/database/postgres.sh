#!/bin/bash

function Database::haveTables() {
    tableCount=$(
        Compose::exec <<'EOF'
        export VERBOSE=0
        export PGPASSWORD="${SPRYKER_DB_ROOT_PASSWORD}"
        databases="$(echo ${SPRYKER_PAAS_SERVICES} | jq  '.databases')";
        if [ -z "${databases}" ] || [ "${databases}" == "[]" ]; then
            psql -lqt \
                -h "${SPRYKER_DB_HOST}" \
                -U "${SPRYKER_DB_ROOT_USERNAME}" |
                grep "${SPRYKER_DB_DATABASE}" >/dev/null 2>&1 &&
                psql \
                    -h "${SPRYKER_DB_HOST}" \
                    -U "${SPRYKER_DB_ROOT_USERNAME}" \
                    "${SPRYKER_DB_DATABASE}" \
                    -c "SELECT count(*) FROM information_schema.tables WHERE table_catalog = '${SPRYKER_DB_DATABASE}';" -t 2>&1 |
                tr -d ' \n\r' ||
                echo 0
        else
            echo ${databases} | jq -c '.[]' | while read line; do
                SPRYKER_DB_HOST=$(echo $line | jq -r .host);
                SPRYKER_DB_DATABASE=$(echo $line | jq -r .database);
                tablesCountPerDb=$(psql -lqt \
                    -h "${SPRYKER_DB_HOST}" \
                    -U "${SPRYKER_DB_ROOT_USERNAME}" |
                    grep "${SPRYKER_DB_DATABASE}" >/dev/null 2>&1 &&
                    psql \
                        -h "${SPRYKER_DB_HOST}" \
                        -U "${SPRYKER_DB_ROOT_USERNAME}" \
                        "${SPRYKER_DB_DATABASE}" \
                        -c "SELECT count(*) FROM information_schema.tables WHERE table_catalog = '${SPRYKER_DB_DATABASE}';" -t 2>&1 |
                    tr -d ' \n\r' ||
                    echo 0)

                if [ "$tablesCountPerDb" == 0 ]; then
                    echo 0;
                    break
                fi

            done

            echo 1;
        fi
EOF
    )

    [ "${tableCount}" -gt 0 ] && return "${TRUE}" || return "${FALSE}"
}

function Database::init() {
    Compose::exec <<'EOF'
        export VERBOSE=0
        export PGPASSWORD="${SPRYKER_DB_ROOT_PASSWORD}"

        databases="$(echo ${SPRYKER_PAAS_SERVICES} | jq  '.databases')";

        if [ -z "${databases}" ] || [ "${databases}" == "[]" ]; then
            psql \
                -h "${SPRYKER_DB_HOST}" \
                -U "${SPRYKER_DB_ROOT_USERNAME}" \
                -tc "SELECT COUNT(*) FROM pg_catalog.pg_roles WHERE rolname = '${SPRYKER_DB_USERNAME}'" |
                grep -q 1 ||
                psql \
                    -h "${SPRYKER_DB_HOST}" \
                    -U "${SPRYKER_DB_ROOT_USERNAME}" \
                    -c "CREATE ROLE \"${SPRYKER_DB_USERNAME}\" LOGIN PASSWORD '${SPRYKER_DB_PASSWORD}';"

            psql -lqt \
                -h "${SPRYKER_DB_HOST}" \
                -U "${SPRYKER_DB_USERNAME}" |
                grep "${SPRYKER_DB_DATABASE}" >/dev/null 2>&1 ||
                psql \
                    -h "${SPRYKER_DB_HOST}" \
                    -U "${SPRYKER_DB_ROOT_USERNAME}" \
                    -tc "CREATE DATABASE \"${SPRYKER_DB_DATABASE}\" OWNER = \"${SPRYKER_DB_USERNAME}\" ENCODING = 'UTF-8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' CONNECTION LIMIT=-1 TEMPLATE=\"template0\";"

            psql \
                -h "${SPRYKER_DB_HOST}" \
                -U "${SPRYKER_DB_ROOT_USERNAME}" \
                -tc "GRANT ALL PRIVILEGES ON DATABASE \"${SPRYKER_DB_DATABASE}\" TO \"${SPRYKER_DB_ROOT_USERNAME}\""
        else
            echo ${databases} | jq -c '.[]' | while read line; do
              SPRYKER_DB_HOST=$(echo $line | jq -r .host);
              SPRYKER_DB_USERNAME=$(echo $line | jq -r .username);
              SPRYKER_DB_PASSWORD=$(echo $line | jq -r .password);
              SPRYKER_DB_DATABASE=$(echo $line | jq -r .database);
              SPRYKER_DB_CHARACTER_SET=$(echo $line | jq -r .characterSet);
              SPRYKER_DB_COLLATE=$(echo $line | jq -r .collate);

              psql \
                -h "${SPRYKER_DB_HOST}" \
                -U "${SPRYKER_DB_ROOT_USERNAME}" \
                -tc "SELECT COUNT(*) FROM pg_catalog.pg_roles WHERE rolname = '${SPRYKER_DB_USERNAME}'" |
                grep -q 1 ||
                psql \
                    -h "${SPRYKER_DB_HOST}" \
                    -U "${SPRYKER_DB_ROOT_USERNAME}" \
                    -c "CREATE ROLE \"${SPRYKER_DB_USERNAME}\" LOGIN PASSWORD '${SPRYKER_DB_PASSWORD}';"

              psql -lqt \
                -h "${SPRYKER_DB_HOST}" \
                -U "${SPRYKER_DB_USERNAME}" |
                grep "${SPRYKER_DB_DATABASE}" >/dev/null 2>&1 ||
                psql \
                    -h "${SPRYKER_DB_HOST}" \
                    -U "${SPRYKER_DB_ROOT_USERNAME}" \
                    -tc "CREATE DATABASE \"${SPRYKER_DB_DATABASE}\" OWNER = \"${SPRYKER_DB_USERNAME}\" ENCODING = 'UTF-8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' CONNECTION LIMIT=-1 TEMPLATE=\"template0\";"

              psql \
                -h "${SPRYKER_DB_HOST}" \
                -U "${SPRYKER_DB_ROOT_USERNAME}" \
                -tc "GRANT ALL PRIVILEGES ON DATABASE \"${SPRYKER_DB_DATABASE}\" TO \"${SPRYKER_DB_ROOT_USERNAME}\""

            done
        fi
EOF
}
