#!/bin/bash

PG_DB_USER="$1"
PG_DB_USER_PASS="$2"
PG_DB_NAME="$3"

help_usage(){
	echo "USAGE: scriptname PG_DB_USER  PG_DB_USER_PASS PG_DB_NAME"
	echo "EXAMPLE:  /bin/bash /pgscripts/02-create-db.sh \"user1\" \"123123\" \"test_db\""
}


check_variables() {
pattern=$'*( |\t)'
if [[ ${PG_DB_USER} = $pattern ]]; then
    echo "First parameter PG_DB_USER has no non-whitespace characters"
    exit 1
fi
if [[ ${PG_DB_USER_PASS} = $pattern ]]; then
    echo "Second parameter PG_DB_USER_PASS has no non-whitespace characters"
    exit 1
fi
if [[ ${PG_DB_NAME} = $pattern ]]; then
    echo "Third parameter PG_DB_NAME has no non-whitespace characters"
    exit 1
fi
}



create_db() {
echo "Creating user ${PG_DB_USER} with password ${PG_DB_USER_PASS}"



PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" <<-EOSQL
    create role "${PG_DB_USER}" with password '${PG_DB_USER_PASS}' login;
    CREATE DATABASE "${PG_DB_NAME}" WITH OWNER "${PG_DB_USER}" ENCODING 'UTF8'  LC_COLLATE 'ru_RU.UTF-8' LC_CTYPE 'ru_RU.utf8' TEMPLATE template0;
EOSQL

echo "GRANT PRIVILEGES ON ${PG_DB_NAME} to USER ${PG_DB_USER}"
PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" <<-EOSQL
    GRANT ALL PRIVILEGES on DATABASE "${PG_DB_NAME}" to "${PG_DB_USER}";
EOSQL

}


create_extensions() {
EXTENSIONS=$(echo ${POSTGRES_EXTENSIONS} | tr "," "\n")
echo "Creating postgres extension with list ${POSTGRES_EXTENSIONS}"
for EXTENSION in ${EXTENSIONS}
do
    echo "Create extension ${EXTENSION} in ${PG_DB_NAME}";
    PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"  -qAt -c "CREATE EXTENSION IF NOT EXISTS \"${EXTENSION}\";" "${PG_DB_NAME}"
done

}

##############
help_usage
check_variables
create_db
create_extensions