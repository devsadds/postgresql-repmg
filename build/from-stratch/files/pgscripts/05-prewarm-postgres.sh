#!/bin/bash
##############
PG_DB_NAME=$1 #db_name
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

}

prewarm_postgres() {

echo -e "${CYAN} Начинаем hразогрев базы ${PG_DB_NAME}. Время начала  ${DATETIME} ${NC}"

echo -e "${CYAN} Creating extension prewarm_postgres if not exist in ${PG_DB_NAME} ${NC}"

PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"  -qAt -c 'CREATE EXTENSION IF NOT EXISTS pg_prewarm;' ${PG_DB_NAME};

for tbl in `PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"    -qAt -c "select tablename from pg_tables where schemaname = 'public';" ${PG_DB_NAME}`;
do
    echo -e "${CYAN} MAKE WARM UP TABLE $tbl in DATABASE ${PG_DB_NAME} begin at ${DATETIME}${NC}"
    PGPASSWORD=${POSTGRESQL_PASSWORD} psql --username="$POSTGRESQL_USERNAME"   -c "SELECT pg_prewarm('$tbl')" ${PG_DB_NAME};
    echo -e "${GREEN} MAKE WARM UP TABLE $tbl in DATABASE ${PG_DB_NAME} finished at ${DATETIME}${NC}"

done
echo -e "${BLUE} Разогрев базы ${PG_DB_NAME} закончен в ${DATETIME} ${NC}"
}


precheck
prewarm_postgres


