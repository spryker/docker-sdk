#!/bin/bash

function Database::haveTables() {
    tableCount=$(
        Compose::exec <<'EOF'
        export VERBOSE=0
        export MYSQL_PWD="${SPRYKER_DB_ROOT_PASSWORD}"
        mysql \
        -h "${SPRYKER_DB_HOST}" \
        -u "${SPRYKER_DB_ROOT_USERNAME}" \
        -e "SELECT TABLE_NAME FROM information_schema.tables WHERE table_schema = \"${SPRYKER_DB_DATABASE}\"" \
        | wc -l \
        |  sed "s/^ *//" \
        | tr -d " \n\r" \
        || echo 0
EOF
    )

    [ "$tableCount" -gt 0 ] && return "${TRUE}" || return "${FALSE}"
}

function Database::init() {
    Compose::exec <<'EOF'
        export MYSQL_PWD="${SPRYKER_DB_ROOT_PASSWORD}"
        mysql \
        -h "${SPRYKER_DB_HOST}" \
        -u root \
        -e "CREATE DATABASE IF NOT EXISTS \`${SPRYKER_DB_DATABASE}\` CHARACTER SET \"${SPRYKER_DB_CHARACTER_SET}\" COLLATE \"${SPRYKER_DB_COLLATE}\"; GRANT ALL PRIVILEGES ON \`${SPRYKER_DB_DATABASE}\`.* TO \"${SPRYKER_DB_USERNAME}\"@\"%\" IDENTIFIED BY \"${SPRYKER_DB_PASSWORD}\" WITH GRANT OPTION;"
EOF
}
