[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

### Simple snippet to migrate metabase application db

The aims of this snippet is migrate metabase application database from MySQL to Postgres. To do this task here we'll use PgLoader through Docker.

Requirements:
- docker
- docker-compose

Usage:

1. Start and prepare MySQL

```shell
make init-mysql
``` 

Inspect if MySQL has started and is waiting connections:

```shell
docker logs $(docker ps | grep mysql | cut -d " " -f 1)
``` 

Then:

```shell
make prepare-mysql
```

2. Start Metabase with MySQL

```shell
init-metabase
``` 

3. Open Metabase e configure it:

 - [localhost:3000](http://localhost:3000)

**You can create some questions with the sample database :)** 

4. Start and prepare Postgresql:

```shell
make init-postgres
``` 

Inspect if Postgres has started and is waiting connections:
```shell
docker logs $(docker ps | grep postgres | cut -d " " -f 1)
``` 

Then:

```shell
make prepare-postgres
``` 
This will create Metabase app database, schema and start a Metabase container which will create all Metabase tables. Metabase create tables using [Liquibase](https://www.liquibase.org/get-started/how-liquibase-works). 

After Metabase has initialized, you can stop the Metabase container. However, you could keep the Metabase container up and execute the next step to migrate data. This will migrate data on the fly. In our tests it worked well, including migration of user sessions.

5. Now you can migrate Metabase data from MySQL to Postgres:

```shell
make migrate-data-to-postgres
```
This will execute PgLoader migrating only data from MySQL to Postgres using this [load script](https://github.com/amommendes/metabase-migration/blob/master/scripts/sql/migrator.load)

Start Metabase with Postgres

```shell
make metabase-postgres
```

If all worked well, go to Metabase and check the migration.
