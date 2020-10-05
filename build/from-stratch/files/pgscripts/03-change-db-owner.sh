#!/bin/bash
##############
PG_DB_USER=$1
PG_DB_NAME=$2
##############



help_usage(){
	echo "USAGE: scriptname PG_DB_USER  PG_DB_NAME"
	echo "EXAMPLE:  /bin/bash /pgscripts/03-change-db-owner.sh \"user1\" \"test_db\""
}



check_variables() {
pattern=$'*( |\t)'
if [[ ${PG_DB_USER} = $pattern ]]; then
    echo "First parameter PG_DB_USER has no non-whitespace characters"
    exit 1
fi
if [[ ${PG_DB_NAME} = $pattern ]]; then
    echo "Third parameter PG_DB_NAME has no non-whitespace characters"
    exit 1
fi
}



rights_db() {
    echo "Изменяем владельца базы ${PG_DB_NAME} на  ${PG_DB_USER}"
for tbl in `PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"    -qAt -c "select tablename from pg_tables where schemaname = 'public';" ${PG_DB_NAME}` \
           `PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"    -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" ${PG_DB_NAME}` \
           `PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"    -qAt -c "select table_name from information_schema.views where table_schema = 'public';" ${PG_DB_NAME}` ;
do
	  echo "ALTER TABLE $tbl in DATABASE ${PG_DB_NAME} TO USER ${PG_DB_USER}"
    PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"   -c "alter table \"$tbl\" owner to \"${PG_DB_USER}\"" ${PG_DB_NAME} ;
done

}




rights_func() {
  IFS=$'\n'
for fnc in `PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" -qAt -c "SELECT  '\"' || p.proname||'\"' || '(' || pg_catalog.pg_get_function_identity_arguments(p.oid) || ')' FROM pg_catalog.pg_namespace n JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid WHERE n.nspname = 'public';" ${PG_DB_NAME}`
do
  echo "ALTER function $fnc in DATABASE ${PG_DB_NAME} TO USER ${PG_DB_USER}"
  PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" -c "alter function $fnc owner to \"${PG_DB_USER}\"" ${PG_DB_NAME} ;
done
}

rights_func_reports() {
  PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" -c "ALTER SCHEMA public OWNER TO \"${PG_DB_USER}\"" ${PG_DB_NAME} ;

}





main() {

help_usage
check_variables
rights_func_reports
rights_db
rights_func

}

main
