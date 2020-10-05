postgresroot() {
	echo "Run psql"
	PGPASSWORD=${POSTGRESQL_PASSWORD} psql  --username "$POSTGRESQL_USERNAME"
}
