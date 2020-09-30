SHELL:=/bin/bash

PSQL_ID=`docker ps | grep postgres | cut -d " " -f 1`
MYSQL_ID=`docker ps | grep mysql | cut -d " " -f 1`
MIGRATOR_ID=`docker ps | grep migrator | cut -d " " -f 1`

# Docker-compose environment
.PHONY: env-postgres
env-postgres:
	@sed -i 's/mysql.env/postgres.env/g' docker-compose.yml

.PHONY: env-mysql
env-mysql:
	@sed -i 's/postgres.env/mysql.env/g' docker-compose.yml

.PHONY: env-aws-postgres
env-aws-postgres:
	@sed -i 's/mysql-aws.env/postgres-aws.env/g' docker-compose.yml

.PHONY: env-aws-mysql
env-aws-mysql:
	@sed -i 's/postgres-aws.env/mysql-aws.env/g' docker-compose.yml


.PHONY: init-mysql
init-mysql:
	@sudo rm -rf mysql
	@sudo docker-compose up -d --force-recreate mysql-db
	@sudo chmod -R 777 mysql

.PHONY: prepare-mysql
prepare-mysql:
	@sudo docker exec -it $(MYSQL_ID) mysql "-uroot" "--password=changeme" "-e" "DROP DATABASE IF EXISTS metabase;"
	@sudo docker exec -it $(MYSQL_ID) mysql "-uroot" "--password=changeme" "-e" "CREATE DATABASE metabase;"
	@sudo docker exec -it $(MYSQL_ID) mysql "-uroot" "--password=changeme" "metabase" "-e" "GRANT ALL ON metabase.* TO metabase@'%';"

.PHONY: init-postgres
init-postgres:
	@sudo rm -rf pgdata && mkdir pgdata
	@sudo docker-compose up -d --force-recreate postgres-db

PHONY: prepare-postgres
prepare-postgres:
	@docker cp ./scripts/sql $(PSQL_ID):/tmp
	@docker exec -it $(PSQL_ID) psql -Umetabase --dbname=postgres --file="/tmp/sql/drop_database.sql"
	@docker exec -it $(PSQL_ID) psql -Umetabase --dbname=postgres --file=/tmp/sql/create_database.sql
	@docker exec -it $(PSQL_ID) psql -Umetabase --dbname=metabase --file=/tmp/sql/functions.sql
	@make env-postgres
	@docker-compose up --force-recreate	metabase
	

.PHONY: init-metabase
init-metabase: env-mysql
	@docker-compose up metabase

.PHONY: put-databases
put-databases: 
	@scripts/put_databases.sh

.PHONY: up-migrator
up-migrator:
	@sudo docker-compose up --force-recreate -d migrator

.PHONY: migrate-data-to-postgres
migrate-data-to-postgres: up-migrator 
	@if test -z "$$LOAD_FILE"; then LOAD_FILE=migrator.load && echo "Using default Load file: $$LOAD_FILE"; else echo Provided load file: $$LOAD_FILE ; fi; \
	sudo docker cp scripts/sql/$$LOAD_FILE $(MIGRATOR_ID):/tmp  && \
	sudo docker exec -it $(MIGRATOR_ID) pgloader /tmp/$$LOAD_FILE


.PHONY: metabase-postgres
metabase-postgres: env-postgres
	@sudo docker-compose up metabase

.PHONY: test-var
test-var:
	