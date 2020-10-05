#!/bin/bash

PG_DB_NAME=$1 #db_name
maintenance_work_mem_vacuum="128"
#    .---------- constant part!
#    vvvv vvvv-- the code from above
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
#    .----------
DATETIME=$(date +%F_+%T) #date


precheck () {

if [ "${PG_DB_NAME}" == "" ];
then
echo -e "${RED} Arg 1 - \"PG_DB_NAME\" is empty. Stop script  ${DATETIME} ${NC}"
exit 1
fi

if [ "${maintenance_work_mem_vacuum}" == "" ];
then
echo -e "${RED} maintenance_work_mem_vacuum is empty. Stop script  ${DATETIME} ${NC}"
exit 1
fi


}

vacuum_full_anazize_postgres() {

maintenance_work_mem_default=$(PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" -c "SHOW maintenance_work_mem;" | grep -ve '(' | grep -o [0-9]*)

echo -e "${CYAN} Начинаем full vacuum analyze базы ${PG_DB_NAME}. Время начала  ${DATETIME} ${NC}"
echo -e "${GREEN} Default maintenance_work_mem if ${maintenance_work_mem_default} ${NC}"
echo -e "${CYAN} SET maintenance_work_mem TO ${maintenance_work_mem_vacuum} ${DATETIME} ${NC}"

	PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" -qAt -c "SET maintenance_work_mem TO '${maintenance_work_mem_vacuum} MB';";

for tbl in `PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"    -qAt -c "select tablename from pg_tables where schemaname = 'public';" ${PG_DB_NAME}`;
 
do
	echo -e "${CYAN} MAKE full vacuum analyze E $tbl in DATABASE ${PG_DB_NAME} begin at ${DATETIME}${NC}"
    PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME" -c "VACUUM (VERBOSE, ANALYZE)  \"$tbl\"" ${PG_DB_NAME};
    echo -e "${GREEN} MAKE full vacuum analyze  $tbl in DATABASE ${PG_DB_NAME} finished at ${DATETIME}${NC}"

done

echo -e "${CYAN} SET maintenance_work_mem TO ${maintenance_work_mem_default} ${DATETIME} ${NC}"
	PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"   -c "SET maintenance_work_mem TO '${maintenance_work_mem_default} MB';";

echo -e "${BLUE} full vacuum analyze базы ${PG_DB_NAME} закончен в ${DATETIME} ${NC}"
}

vacuum_full_anazize_show_statistic() {
echo -e "${CYAN} !!!!SHOW STATISTICS POSTGRES VACUUM!!! ${NC}"
PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"   -c "SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze   FROM pg_stat_all_tables  WHERE schemaname = 'public';"  
}

precheck
vacuum_full_anazize_postgres
vacuum_full_anazize_show_statistic