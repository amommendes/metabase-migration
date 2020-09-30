-- *********************************************************************
-- Update Database Script
-- *********************************************************************
-- Change Log: liquibase.yaml
-- Ran at: 29/06/2020 20:46
-- Against: Postgresql
-- Liquibase version: 3.6.3
-- *********************************************************************


CREATE TABLE metabase.databasechangelog (
	id varchar(255) NOT NULL,
	author varchar(255) NOT NULL,
	filename varchar(255) NOT NULL,
	dateexecuted timestamp NOT NULL,
	orderexecuted int4 NOT NULL,
	exectype varchar(10) NOT NULL,
	md5sum varchar(35) NULL,
	description varchar(255) NULL,
	"comments" varchar(255) NULL,
	tag varchar(255) NULL,
	liquibase varchar(20) NULL,
	contexts varchar(255) NULL,
	labels varchar(255) NULL,
	deployment_id varchar(10) NULL
);

CREATE TABLE metabase.databasechangeloglock (ID INT NOT NULL, LOCKED BOOLEAN NOT NULL, LOCKGRANTED TIMESTAMP, LOCKEDBY VARCHAR(255), CONSTRAINT PK_DATABASECHANGELOGLOCK PRIMARY KEY (ID));

-- Initialize Database Lock Table
DELETE FROM metabase.databasechangeloglock;

INSERT INTO metabase.databasechangeloglock (ID, LOCKED) VALUES (1, FALSE);

-- Lock Database
UPDATE metabase.databasechangeloglock SET LOCKED = TRUE, LOCKEDBY = '192.168.15.159 (192.168.15.159)', LOCKGRANTED = '2020-06-29 20:46:01.763' WHERE ID = 1 AND LOCKED = FALSE;

-- Initialize Database Lock Table
DELETE FROM metabase.databasechangeloglock;

INSERT INTO metabase.databasechangeloglock (ID, LOCKED) VALUES (1, FALSE);

-- Changeset migrations/000_migrations.yaml::1::agilliland
CREATE TABLE metabase.core_organization (id SERIAL NOT NULL, slug VARCHAR(254) NOT NULL, name VARCHAR(254) NOT NULL, description TEXT, logo_url VARCHAR(254), inherits BOOLEAN NOT NULL, CONSTRAINT CORE_ORGANIZATION_PKEY PRIMARY KEY (id), UNIQUE (slug));

CREATE TABLE metabase.core_user (id SERIAL NOT NULL, email VARCHAR(254) NOT NULL, first_name VARCHAR(254) NOT NULL, last_name VARCHAR(254) NOT NULL, password VARCHAR(254) NOT NULL, password_salt VARCHAR(254) DEFAULT 'default' NOT NULL, date_joined TIMESTAMP WITH TIME ZONE NOT NULL, last_login TIMESTAMP WITH TIME ZONE, is_staff BOOLEAN NOT NULL, is_superuser BOOLEAN NOT NULL, is_active BOOLEAN NOT NULL, reset_token VARCHAR(254), reset_triggered BIGINT, CONSTRAINT CORE_USER_PKEY PRIMARY KEY (id), UNIQUE (email));

CREATE TABLE metabase.core_userorgperm (id SERIAL NOT NULL, admin BOOLEAN NOT NULL, user_id INTEGER NOT NULL, organization_id INTEGER NOT NULL, CONSTRAINT CORE_USERORGPERM_PKEY PRIMARY KEY (id), CONSTRAINT fk_userorgperm_ref_organization_id FOREIGN KEY (organization_id) REFERENCES metabase.core_organization(id), CONSTRAINT fk_userorgperm_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

ALTER TABLE metabase.core_userorgperm ADD CONSTRAINT idx_unique_user_id_organization_id UNIQUE (user_id, organization_id);

CREATE INDEX idx_userorgperm_user_id ON metabase.core_userorgperm(user_id);

CREATE INDEX idx_userorgperm_organization_id ON metabase.core_userorgperm(organization_id);

CREATE TABLE metabase.core_permissionsviolation (id SERIAL NOT NULL, url VARCHAR(254) NOT NULL, timestamp TIMESTAMP WITH TIME ZONE NOT NULL, user_id INTEGER NOT NULL, CONSTRAINT CORE_PERMISSIONSVIOLATION_PKEY PRIMARY KEY (id), CONSTRAINT fk_permissionviolation_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_permissionsviolation_user_id ON metabase.core_permissionsviolation(user_id);

CREATE TABLE metabase.metabase_database (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, description TEXT, organization_id INTEGER NOT NULL, details TEXT, engine VARCHAR(254) NOT NULL, CONSTRAINT METABASE_DATABASE_PKEY PRIMARY KEY (id), CONSTRAINT fk_database_ref_organization_id FOREIGN KEY (organization_id) REFERENCES metabase.core_organization(id));

CREATE INDEX idx_database_organization_id ON metabase.metabase_database(organization_id);

CREATE TABLE metabase.metabase_table (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, rows INTEGER, description TEXT, entity_name VARCHAR(254), entity_type VARCHAR(254), active BOOLEAN NOT NULL, db_id INTEGER NOT NULL, CONSTRAINT METABASE_TABLE_PKEY PRIMARY KEY (id), CONSTRAINT fk_table_ref_database_id FOREIGN KEY (db_id) REFERENCES metabase.metabase_database(id));

CREATE INDEX idx_table_db_id ON metabase.metabase_table(db_id);

CREATE TABLE metabase.metabase_field (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, base_type VARCHAR(255) NOT NULL, special_type VARCHAR(255), active BOOLEAN NOT NULL, description TEXT, preview_display BOOLEAN NOT NULL, position INTEGER NOT NULL, table_id INTEGER NOT NULL, field_type VARCHAR(254) NOT NULL, CONSTRAINT METABASE_FIELD_PKEY PRIMARY KEY (id), CONSTRAINT fk_field_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase.metabase_table(id));

CREATE INDEX idx_field_table_id ON metabase.metabase_field(table_id);

CREATE TABLE metabase.metabase_foreignkey (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, relationship VARCHAR(254) NOT NULL, destination_id INTEGER NOT NULL, origin_id INTEGER NOT NULL, CONSTRAINT METABASE_FOREIGNKEY_PKEY PRIMARY KEY (id), CONSTRAINT fk_foreignkey_dest_ref_field_id FOREIGN KEY (destination_id) REFERENCES metabase.metabase_field(id), CONSTRAINT fk_foreignkey_origin_ref_field_id FOREIGN KEY (origin_id) REFERENCES metabase.metabase_field(id));

CREATE INDEX idx_foreignkey_destination_id ON metabase.metabase_foreignkey(destination_id);

CREATE INDEX idx_foreignkey_origin_id ON metabase.metabase_foreignkey(origin_id);

CREATE TABLE metabase.metabase_fieldvalues (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, values TEXT, human_readable_values TEXT, field_id INTEGER NOT NULL, CONSTRAINT METABASE_FIELDVALUES_PKEY PRIMARY KEY (id), CONSTRAINT fk_fieldvalues_ref_field_id FOREIGN KEY (field_id) REFERENCES metabase.metabase_field(id));

CREATE INDEX idx_fieldvalues_field_id ON metabase.metabase_fieldvalues(field_id);

CREATE TABLE metabase.metabase_tablesegment (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, table_id INTEGER NOT NULL, filter_clause TEXT NOT NULL, CONSTRAINT METABASE_TABLESEGMENT_PKEY PRIMARY KEY (id), CONSTRAINT fk_tablesegment_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase.metabase_table(id));

CREATE INDEX idx_tablesegment_table_id ON metabase.metabase_tablesegment(table_id);

CREATE TABLE metabase.query_query (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, type VARCHAR(254) NOT NULL, details TEXT NOT NULL, version INTEGER NOT NULL, public_perms INTEGER NOT NULL, creator_id INTEGER NOT NULL, database_id INTEGER NOT NULL, CONSTRAINT QUERY_QUERY_PKEY PRIMARY KEY (id), CONSTRAINT fk_query_ref_database_id FOREIGN KEY (database_id) REFERENCES metabase.metabase_database(id), CONSTRAINT fk_query_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_query_creator_id ON metabase.query_query(creator_id);

CREATE INDEX idx_query_database_id ON metabase.query_query(database_id);

CREATE TABLE metabase.query_queryexecution (id SERIAL NOT NULL, uuid VARCHAR(254) NOT NULL, version INTEGER NOT NULL, json_query TEXT NOT NULL, raw_query TEXT NOT NULL, status VARCHAR(254) NOT NULL, started_at TIMESTAMP WITH TIME ZONE NOT NULL, finished_at TIMESTAMP WITH TIME ZONE, running_time INTEGER NOT NULL, error TEXT NOT NULL, result_file VARCHAR(254) NOT NULL, result_rows INTEGER NOT NULL, result_data TEXT NOT NULL, query_id INTEGER, additional_info TEXT NOT NULL, executor_id INTEGER NOT NULL, CONSTRAINT QUERY_QUERYEXECUTION_PKEY PRIMARY KEY (id), CONSTRAINT fk_queryexecution_ref_query_id FOREIGN KEY (query_id) REFERENCES metabase.query_query(id), CONSTRAINT fk_queryexecution_ref_user_id FOREIGN KEY (executor_id) REFERENCES metabase.core_user(id), UNIQUE (uuid));

CREATE INDEX idx_queryexecution_query_id ON metabase.query_queryexecution(query_id);

CREATE INDEX idx_queryexecution_executor_id ON metabase.query_queryexecution(executor_id);

CREATE TABLE metabase.report_card (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, description TEXT, display VARCHAR(254) NOT NULL, public_perms INTEGER NOT NULL, dataset_query TEXT NOT NULL, visualization_settings TEXT NOT NULL, creator_id INTEGER NOT NULL, organization_id INTEGER NOT NULL, CONSTRAINT REPORT_CARD_PKEY PRIMARY KEY (id), CONSTRAINT fk_card_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id), CONSTRAINT fk_card_ref_organization_id FOREIGN KEY (organization_id) REFERENCES metabase.core_organization(id));

CREATE INDEX idx_card_creator_id ON metabase.report_card(creator_id);

CREATE INDEX idx_card_organization_id ON metabase.report_card(organization_id);

CREATE TABLE metabase.report_cardfavorite (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, card_id INTEGER NOT NULL, owner_id INTEGER NOT NULL, CONSTRAINT REPORT_CARDFAVORITE_PKEY PRIMARY KEY (id), CONSTRAINT fk_cardfavorite_ref_user_id FOREIGN KEY (owner_id) REFERENCES metabase.core_user(id), CONSTRAINT fk_cardfavorite_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase.report_card(id));

ALTER TABLE metabase.report_cardfavorite ADD CONSTRAINT idx_unique_cardfavorite_card_id_owner_id UNIQUE (card_id, owner_id);

CREATE INDEX idx_cardfavorite_card_id ON metabase.report_cardfavorite(card_id);

CREATE INDEX idx_cardfavorite_owner_id ON metabase.report_cardfavorite(owner_id);

CREATE TABLE metabase.report_dashboard (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, description TEXT, public_perms INTEGER NOT NULL, creator_id INTEGER NOT NULL, organization_id INTEGER NOT NULL, CONSTRAINT REPORT_DASHBOARD_PKEY PRIMARY KEY (id), CONSTRAINT fk_dashboard_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id), CONSTRAINT fk_dashboard_ref_organization_id FOREIGN KEY (organization_id) REFERENCES metabase.core_organization(id));

CREATE INDEX idx_dashboard_creator_id ON metabase.report_dashboard(creator_id);

CREATE INDEX idx_dashboard_organization_id ON metabase.report_dashboard(organization_id);

CREATE TABLE metabase.report_dashboardcard (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, "sizeX" INTEGER NOT NULL, "sizeY" INTEGER NOT NULL, row INTEGER, col INTEGER, card_id INTEGER NOT NULL, dashboard_id INTEGER NOT NULL, CONSTRAINT REPORT_DASHBOARDCARD_PKEY PRIMARY KEY (id), CONSTRAINT fk_dashboardcard_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase.report_card(id), CONSTRAINT fk_dashboardcard_ref_dashboard_id FOREIGN KEY (dashboard_id) REFERENCES metabase.report_dashboard(id));

CREATE INDEX idx_dashboardcard_card_id ON metabase.report_dashboardcard(card_id);

CREATE INDEX idx_dashboardcard_dashboard_id ON metabase.report_dashboardcard(dashboard_id);

CREATE TABLE metabase.report_dashboardsubscription (id SERIAL NOT NULL, dashboard_id INTEGER NOT NULL, user_id INTEGER NOT NULL, CONSTRAINT REPORT_DASHBOARDSUBSCRIPTION_PKEY PRIMARY KEY (id), CONSTRAINT fk_dashboardsubscription_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id), CONSTRAINT fk_dashboardsubscription_ref_dashboard_id FOREIGN KEY (dashboard_id) REFERENCES metabase.report_dashboard(id));

ALTER TABLE metabase.report_dashboardsubscription ADD CONSTRAINT idx_uniq_dashsubscrip_dashboard_id_user_id UNIQUE (dashboard_id, user_id);

CREATE INDEX idx_dashboardsubscription_dashboard_id ON metabase.report_dashboardsubscription(dashboard_id);

CREATE INDEX idx_dashboardsubscription_user_id ON metabase.report_dashboardsubscription(user_id);

CREATE TABLE metabase.report_emailreport (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, name VARCHAR(254) NOT NULL, description TEXT, public_perms INTEGER NOT NULL, mode INTEGER NOT NULL, version INTEGER NOT NULL, dataset_query TEXT NOT NULL, email_addresses TEXT, creator_id INTEGER NOT NULL, organization_id INTEGER NOT NULL, schedule TEXT NOT NULL, CONSTRAINT REPORT_EMAILREPORT_PKEY PRIMARY KEY (id), CONSTRAINT fk_emailreport_ref_organization_id FOREIGN KEY (organization_id) REFERENCES metabase.core_organization(id), CONSTRAINT fk_emailreport_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_emailreport_creator_id ON metabase.report_emailreport(creator_id);

CREATE INDEX idx_emailreport_organization_id ON metabase.report_emailreport(organization_id);

CREATE TABLE metabase.report_emailreport_recipients (id SERIAL NOT NULL, emailreport_id INTEGER NOT NULL, user_id INTEGER NOT NULL, CONSTRAINT REPORT_EMAILREPORT_RECIPIENTS_PKEY PRIMARY KEY (id), CONSTRAINT fk_emailreport_recipients_ref_emailreport_id FOREIGN KEY (emailreport_id) REFERENCES metabase.report_emailreport(id), CONSTRAINT fk_emailreport_recipients_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

ALTER TABLE metabase.report_emailreport_recipients ADD CONSTRAINT idx_uniq_emailreportrecip_emailreport_id_user_id UNIQUE (emailreport_id, user_id);

CREATE INDEX idx_emailreport_recipients_emailreport_id ON metabase.report_emailreport_recipients(emailreport_id);

CREATE INDEX idx_emailreport_recipients_user_id ON metabase.report_emailreport_recipients(user_id);

CREATE TABLE metabase.report_emailreportexecutions (id SERIAL NOT NULL, details TEXT NOT NULL, status VARCHAR(254) NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, started_at TIMESTAMP WITH TIME ZONE, finished_at TIMESTAMP WITH TIME ZONE, error TEXT NOT NULL, sent_email TEXT NOT NULL, organization_id INTEGER NOT NULL, report_id INTEGER, CONSTRAINT REPORT_EMAILREPORTEXECUTIONS_PKEY PRIMARY KEY (id), CONSTRAINT fk_emailreportexecutions_ref_organization_id FOREIGN KEY (organization_id) REFERENCES metabase.core_organization(id), CONSTRAINT fk_emailreportexecutions_ref_report_id FOREIGN KEY (report_id) REFERENCES metabase.report_emailreport(id));

CREATE INDEX idx_emailreportexecutions_organization_id ON metabase.report_emailreportexecutions(organization_id);

CREATE INDEX idx_emailreportexecutions_report_id ON metabase.report_emailreportexecutions(report_id);

CREATE TABLE metabase.annotation_annotation (id SERIAL NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, start TIMESTAMP WITH TIME ZONE NOT NULL, "end" TIMESTAMP WITH TIME ZONE NOT NULL, title TEXT, body TEXT NOT NULL, annotation_type INTEGER NOT NULL, edit_count INTEGER NOT NULL, object_type_id INTEGER NOT NULL, object_id INTEGER NOT NULL, author_id INTEGER NOT NULL, organization_id INTEGER NOT NULL, CONSTRAINT ANNOTATION_ANNOTATION_PKEY PRIMARY KEY (id), CONSTRAINT fk_annotation_ref_user_id FOREIGN KEY (author_id) REFERENCES metabase.core_user(id), CONSTRAINT fk_annotation_ref_organization_id FOREIGN KEY (organization_id) REFERENCES metabase.core_organization(id));

CREATE INDEX idx_annotation_author_id ON metabase.annotation_annotation(author_id);

CREATE INDEX idx_annotation_organization_id ON metabase.annotation_annotation(organization_id);

CREATE INDEX idx_annotation_object_type_id ON metabase.annotation_annotation(object_type_id);

CREATE INDEX idx_annotation_object_id ON metabase.annotation_annotation(object_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('1', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 1, '8:7182ca8e82947c24fa827d31f78b19aa', 'createTable tableName=core_organization; createTable tableName=core_user; createTable tableName=core_userorgperm; addUniqueConstraint constraintName=idx_unique_user_id_organization_id, tableName=core_userorgperm; createIndex indexName=idx_userorgp...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::2::agilliland
CREATE TABLE metabase.core_session (id VARCHAR(254) NOT NULL, user_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT CORE_SESSION_PKEY PRIMARY KEY (id), CONSTRAINT fk_session_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('2', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 2, '8:bdcf1238e2ccb4fbe66d7f9e1d9b9529', 'createTable tableName=core_session', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::4::cammsaul
CREATE TABLE metabase.setting (key VARCHAR(254) NOT NULL, value VARCHAR(254) NOT NULL, CONSTRAINT SETTING_PKEY PRIMARY KEY (key));

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('4', 'cammsaul', 'migrations/000_migrations.yaml', NOW(), 3, '8:a8e7822a91ea122212d376f5c2d4158f', 'createTable tableName=setting', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::5::agilliland
ALTER TABLE metabase.core_organization ADD report_timezone VARCHAR(254);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('5', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 4, '8:4f8653d16f4b102b3dff647277b6b988', 'addColumn tableName=core_organization', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::6::agilliland
ALTER TABLE metabase.metabase_database ALTER COLUMN  organization_id DROP NOT NULL;

ALTER TABLE metabase.metabase_database DROP CONSTRAINT fk_database_ref_organization_id;

ALTER TABLE metabase.report_card ALTER COLUMN  organization_id DROP NOT NULL;

ALTER TABLE metabase.report_card DROP CONSTRAINT fk_card_ref_organization_id;

ALTER TABLE metabase.report_dashboard ALTER COLUMN  organization_id DROP NOT NULL;

ALTER TABLE metabase.report_dashboard DROP CONSTRAINT fk_dashboard_ref_organization_id;

ALTER TABLE metabase.report_emailreport ALTER COLUMN  organization_id DROP NOT NULL;

ALTER TABLE metabase.report_emailreport DROP CONSTRAINT fk_emailreport_ref_organization_id;

ALTER TABLE metabase.report_emailreportexecutions ALTER COLUMN  organization_id DROP NOT NULL;

ALTER TABLE metabase.report_emailreportexecutions DROP CONSTRAINT fk_emailreportexecutions_ref_organization_id;

ALTER TABLE metabase.annotation_annotation ALTER COLUMN  organization_id DROP NOT NULL;

ALTER TABLE metabase.annotation_annotation DROP CONSTRAINT fk_annotation_ref_organization_id;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('6', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 5, '8:2d2f5d1756ecb81da7c09ccfb9b1565a', 'dropNotNullConstraint columnName=organization_id, tableName=metabase_database; dropForeignKeyConstraint baseTableName=metabase_database, constraintName=fk_database_ref_organization_id; dropNotNullConstraint columnName=organization_id, tableName=re...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::7::cammsaul
ALTER TABLE metabase.metabase_field ADD parent_id INTEGER;

ALTER TABLE metabase.metabase_field ADD CONSTRAINT fk_field_parent_ref_field_id FOREIGN KEY (parent_id) REFERENCES metabase.metabase_field (id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('7', 'cammsaul', 'migrations/000_migrations.yaml', NOW(), 6, '8:c57c69fd78d804beb77d261066521f7f', 'addColumn tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::8::tlrobinson
ALTER TABLE metabase.metabase_table ADD display_name VARCHAR(254);

ALTER TABLE metabase.metabase_field ADD display_name VARCHAR(254);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('8', 'tlrobinson', 'migrations/000_migrations.yaml', NOW(), 7, '8:960ec59bbcb4c9f3fa8362eca9af4075', 'addColumn tableName=metabase_table; addColumn tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::9::tlrobinson
ALTER TABLE metabase.metabase_table ADD visibility_type VARCHAR(254);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('9', 'tlrobinson', 'migrations/000_migrations.yaml', NOW(), 8, '8:d560283a190e3c60802eb04f5532a49d', 'addColumn tableName=metabase_table', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::10::cammsaul
CREATE TABLE metabase.revision (id SERIAL NOT NULL, model VARCHAR(16) NOT NULL, model_id INTEGER NOT NULL, user_id INTEGER NOT NULL, timestamp TIMESTAMP WITH TIME ZONE NOT NULL, object VARCHAR NOT NULL, is_reversion BOOLEAN DEFAULT FALSE NOT NULL, CONSTRAINT REVISION_PKEY PRIMARY KEY (id), CONSTRAINT fk_revision_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_revision_model_model_id ON metabase.revision(model, model_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('10', 'cammsaul', 'migrations/000_migrations.yaml', NOW(), 9, '8:9f03a236be31f54e8e5c894fe5fc7f00', 'createTable tableName=revision; createIndex indexName=idx_revision_model_model_id, tableName=revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::11::agilliland
update metabase.report_dashboard set public_perms = 2 where public_perms = 1;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('11', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 10, '8:ca6561cab1eedbcf4dcb6d6e22cd46c6', 'sql', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::12::agilliland
ALTER TABLE metabase.report_card ADD database_id INTEGER;

ALTER TABLE metabase.report_card ADD CONSTRAINT fk_report_card_ref_database_id FOREIGN KEY (database_id) REFERENCES metabase.metabase_database (id);

ALTER TABLE metabase.report_card ADD table_id INTEGER;

ALTER TABLE metabase.report_card ADD CONSTRAINT fk_report_card_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase.metabase_table (id);

ALTER TABLE metabase.report_card ADD query_type VARCHAR(16);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('12', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 11, '8:bedbea570e5dfc694b4cf5a8f6a4f445', 'addColumn tableName=report_card', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::13::agilliland
CREATE TABLE metabase.activity (id SERIAL NOT NULL, topic VARCHAR(32) NOT NULL, timestamp TIMESTAMP WITH TIME ZONE NOT NULL, user_id INTEGER, model VARCHAR(16), model_id INTEGER, database_id INTEGER, table_id INTEGER, custom_id VARCHAR(48), details VARCHAR NOT NULL, CONSTRAINT ACTIVITY_PKEY PRIMARY KEY (id), CONSTRAINT fk_activity_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_activity_timestamp ON metabase.activity(timestamp);

CREATE INDEX idx_activity_user_id ON metabase.activity(user_id);

CREATE INDEX idx_activity_custom_id ON metabase.activity(custom_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('13', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 12, '8:c2c65930bad8d3e9bab3bb6ae562fe0c', 'createTable tableName=activity; createIndex indexName=idx_activity_timestamp, tableName=activity; createIndex indexName=idx_activity_user_id, tableName=activity; createIndex indexName=idx_activity_custom_id, tableName=activity', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::14::agilliland
CREATE TABLE metabase.view_log (id SERIAL NOT NULL, user_id INTEGER, model VARCHAR(16) NOT NULL, model_id INTEGER NOT NULL, timestamp TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT VIEW_LOG_PKEY PRIMARY KEY (id), CONSTRAINT fk_view_log_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_view_log_user_id ON metabase.view_log(user_id);

CREATE INDEX idx_view_log_timestamp ON metabase.view_log(model_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('14', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 13, '8:320d2ca8ead3f31309674b2b7f54f395', 'createTable tableName=view_log; createIndex indexName=idx_view_log_user_id, tableName=view_log; createIndex indexName=idx_view_log_timestamp, tableName=view_log', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::15::agilliland
ALTER TABLE metabase.revision ADD is_creation BOOLEAN DEFAULT FALSE NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('15', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 14, '8:505b91530103673a9be3382cd2db1070', 'addColumn tableName=revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::16::agilliland
ALTER TABLE metabase.core_user ALTER COLUMN  last_login DROP NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('16', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 15, '8:ecc7f02641a589e6d35f88587ac6e02b', 'dropNotNullConstraint columnName=last_login, tableName=core_user', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::17::agilliland
ALTER TABLE metabase.metabase_database ADD is_sample BOOLEAN DEFAULT FALSE NOT NULL;

update metabase.metabase_database set is_sample = true where name = 'Sample Dataset';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('17', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 16, '8:051c23cd15359364b9895c1569c319e7', 'addColumn tableName=metabase_database; sql', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::18::camsaul
CREATE TABLE metabase.data_migrations (id VARCHAR(254) NOT NULL, timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL, CONSTRAINT DATA_MIGRATIONS_PKEY PRIMARY KEY (id));

CREATE INDEX idx_data_migrations_id ON metabase.data_migrations(id);

-- Skip migrated collections
INSERT INTO metabase.data_migrations (id, timestamp) VALUES ('add-migrated-collections', now()::timestamp);
INSERT INTO metabase.data_migrations (id, "timestamp") VALUES('drop-old-query-execution-table', now()::timestamp);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('18', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 17, '8:62a0483dde183cfd18dd0a86e9354288', 'createTable tableName=data_migrations; createIndex indexName=idx_data_migrations_id, tableName=data_migrations', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::19::camsaul
ALTER TABLE metabase.metabase_table ADD schema VARCHAR(256);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('19', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 18, '8:269b129dbfc39a6f9e0d3bc61c3c3b70', 'addColumn tableName=metabase_table', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::20::agilliland
CREATE TABLE metabase.pulse (id SERIAL NOT NULL, creator_id INTEGER NOT NULL, name VARCHAR(254) NOT NULL, public_perms INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT PULSE_PKEY PRIMARY KEY (id), CONSTRAINT fk_pulse_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_pulse_creator_id ON metabase.pulse(creator_id);

CREATE TABLE metabase.pulse_card (id SERIAL NOT NULL, pulse_id INTEGER NOT NULL, card_id INTEGER NOT NULL, position INTEGER NOT NULL, CONSTRAINT PULSE_CARD_PKEY PRIMARY KEY (id), CONSTRAINT fk_pulse_card_ref_pulse_id FOREIGN KEY (pulse_id) REFERENCES metabase.pulse(id), CONSTRAINT fk_pulse_card_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase.report_card(id));

CREATE INDEX idx_pulse_card_pulse_id ON metabase.pulse_card(pulse_id);

CREATE INDEX idx_pulse_card_card_id ON metabase.pulse_card(card_id);

CREATE TABLE metabase.pulse_channel (id SERIAL NOT NULL, pulse_id INTEGER NOT NULL, channel_type VARCHAR(32) NOT NULL, details TEXT NOT NULL, schedule_type VARCHAR(32) NOT NULL, schedule_hour INTEGER, schedule_day VARCHAR(64), created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT PULSE_CHANNEL_PKEY PRIMARY KEY (id), CONSTRAINT fk_pulse_channel_ref_pulse_id FOREIGN KEY (pulse_id) REFERENCES metabase.pulse(id));

CREATE INDEX idx_pulse_channel_pulse_id ON metabase.pulse_channel(pulse_id);

CREATE INDEX idx_pulse_channel_schedule_type ON metabase.pulse_channel(schedule_type);

CREATE TABLE metabase.pulse_channel_recipient (id SERIAL NOT NULL, pulse_channel_id INTEGER NOT NULL, user_id INTEGER NOT NULL, CONSTRAINT PULSE_CHANNEL_RECIPIENT_PKEY PRIMARY KEY (id), CONSTRAINT fk_pulse_channel_recipient_ref_pulse_channel_id FOREIGN KEY (pulse_channel_id) REFERENCES metabase.pulse_channel(id), CONSTRAINT fk_pulse_channel_recipient_ref_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('20', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 19, '8:0afa34e8b528b83aa19b4142984f8095', 'createTable tableName=pulse; createIndex indexName=idx_pulse_creator_id, tableName=pulse; createTable tableName=pulse_card; createIndex indexName=idx_pulse_card_pulse_id, tableName=pulse_card; createIndex indexName=idx_pulse_card_card_id, tableNam...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::21::agilliland
CREATE TABLE metabase.segment (id SERIAL NOT NULL, table_id INTEGER NOT NULL, creator_id INTEGER NOT NULL, name VARCHAR(254) NOT NULL, description TEXT, is_active BOOLEAN DEFAULT TRUE NOT NULL, definition TEXT NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT SEGMENT_PKEY PRIMARY KEY (id), CONSTRAINT fk_segment_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id), CONSTRAINT fk_segment_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase.metabase_table(id));

CREATE INDEX idx_segment_creator_id ON metabase.segment(creator_id);

CREATE INDEX idx_segment_table_id ON metabase.segment(table_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('21', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 20, '8:fb2cd308b17ab81b502d057ecde4fc1b', 'createTable tableName=segment; createIndex indexName=idx_segment_creator_id, tableName=segment; createIndex indexName=idx_segment_table_id, tableName=segment', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::22::agilliland
ALTER TABLE metabase.revision ADD message TEXT;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('22', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 21, '8:80bc8a62a90791a79adedcf1ac3c6f08', 'addColumn tableName=revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::23::agilliland
ALTER TABLE metabase.metabase_table ALTER COLUMN rows TYPE BIGINT USING (rows::BIGINT);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('23', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 22, '8:b6f054835db2b2688a1be1de3707f9a9', 'modifyDataType columnName=rows, tableName=metabase_table', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::24::agilliland
CREATE TABLE metabase.dependency (id SERIAL NOT NULL, model VARCHAR(32) NOT NULL, model_id INTEGER NOT NULL, dependent_on_model VARCHAR(32) NOT NULL, dependent_on_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT DEPENDENCY_PKEY PRIMARY KEY (id));

CREATE INDEX idx_dependency_model ON metabase.dependency(model);

CREATE INDEX idx_dependency_model_id ON metabase.dependency(model_id);

CREATE INDEX idx_dependency_dependent_on_model ON metabase.dependency(dependent_on_model);

CREATE INDEX idx_dependency_dependent_on_id ON metabase.dependency(dependent_on_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('24', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 23, '8:60825b125b452747098b577310c142b1', 'createTable tableName=dependency; createIndex indexName=idx_dependency_model, tableName=dependency; createIndex indexName=idx_dependency_model_id, tableName=dependency; createIndex indexName=idx_dependency_dependent_on_model, tableName=dependency;...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::25::agilliland
CREATE TABLE metabase.metric (id SERIAL NOT NULL, table_id INTEGER NOT NULL, creator_id INTEGER NOT NULL, name VARCHAR(254) NOT NULL, description TEXT, is_active BOOLEAN DEFAULT TRUE NOT NULL, definition TEXT NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT METRIC_PKEY PRIMARY KEY (id), CONSTRAINT fk_metric_ref_table_id FOREIGN KEY (table_id) REFERENCES metabase.metabase_table(id), CONSTRAINT fk_metric_ref_creator_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id));

CREATE INDEX idx_metric_creator_id ON metabase.metric(creator_id);

CREATE INDEX idx_metric_table_id ON metabase.metric(table_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('25', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 24, '8:61f25563911117df72f5621d78f10089', 'createTable tableName=metric; createIndex indexName=idx_metric_creator_id, tableName=metric; createIndex indexName=idx_metric_table_id, tableName=metric', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::26::agilliland
ALTER TABLE metabase.metabase_database ADD is_full_sync BOOLEAN DEFAULT TRUE NOT NULL;

update metabase.metabase_database set is_full_sync = true;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('26', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 25, '8:ddef40b95c55cf4ac0e6a5161911a4cb', 'addColumn tableName=metabase_database; sql', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::27::agilliland
CREATE TABLE metabase.dashboardcard_series (id SERIAL NOT NULL, dashboardcard_id INTEGER NOT NULL, card_id INTEGER NOT NULL, position INTEGER NOT NULL, CONSTRAINT DASHBOARDCARD_SERIES_PKEY PRIMARY KEY (id), CONSTRAINT fk_dashboardcard_series_ref_dashboardcard_id FOREIGN KEY (dashboardcard_id) REFERENCES metabase.report_dashboardcard(id), CONSTRAINT fk_dashboardcard_series_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase.report_card(id));

CREATE INDEX idx_dashboardcard_series_dashboardcard_id ON metabase.dashboardcard_series(dashboardcard_id);

CREATE INDEX idx_dashboardcard_series_card_id ON metabase.dashboardcard_series(card_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('27', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 26, '8:001855139df2d5dac4eb954e5abe6486', 'createTable tableName=dashboardcard_series; createIndex indexName=idx_dashboardcard_series_dashboardcard_id, tableName=dashboardcard_series; createIndex indexName=idx_dashboardcard_series_card_id, tableName=dashboardcard_series', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::28::agilliland
ALTER TABLE metabase.core_user ADD is_qbnewb BOOLEAN DEFAULT TRUE NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('28', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 27, '8:428e4eb05e4e29141735adf9ae141a0b', 'addColumn tableName=core_user', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::29::agilliland
ALTER TABLE metabase.pulse_channel ADD schedule_frame VARCHAR(32);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('29', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 28, '8:8b02731cc34add3722c926dfd7376ae0', 'addColumn tableName=pulse_channel', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::30::agilliland
ALTER TABLE metabase.metabase_field ADD visibility_type VARCHAR(32);

UPDATE metabase.metabase_field SET visibility_type = 'unset' WHERE visibility_type IS NULL;

ALTER TABLE metabase.metabase_field ALTER COLUMN  visibility_type SET NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('30', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 29, '8:2c3a50cef177cb90d47a9973cd5934e5', 'addColumn tableName=metabase_field; addNotNullConstraint columnName=visibility_type, tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::31::agilliland
ALTER TABLE metabase.metabase_field ADD fk_target_field_id INTEGER;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('31', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 30, '8:30a33a82bab0bcbb2ccb6738d48e1421', 'addColumn tableName=metabase_field', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::32::camsaul
CREATE TABLE metabase.label (id SERIAL NOT NULL, name VARCHAR(254) NOT NULL, slug VARCHAR(254) NOT NULL, icon VARCHAR(128), CONSTRAINT LABEL_PKEY PRIMARY KEY (id), UNIQUE (slug));

CREATE INDEX idx_label_slug ON metabase.label(slug);

CREATE TABLE metabase.card_label (id SERIAL NOT NULL, card_id INTEGER NOT NULL, label_id INTEGER NOT NULL, CONSTRAINT CARD_LABEL_PKEY PRIMARY KEY (id), CONSTRAINT fk_card_label_ref_label_id FOREIGN KEY (label_id) REFERENCES metabase.label(id), CONSTRAINT fk_card_label_ref_card_id FOREIGN KEY (card_id) REFERENCES metabase.report_card(id));

ALTER TABLE metabase.card_label ADD CONSTRAINT unique_card_label_card_id_label_id UNIQUE (card_id, label_id);

CREATE INDEX idx_card_label_card_id ON metabase.card_label(card_id);

CREATE INDEX idx_card_label_label_id ON metabase.card_label(label_id);

ALTER TABLE metabase.report_card ADD archived BOOLEAN DEFAULT FALSE NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('32', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 31, '8:40830260b92cedad8da273afd5eca678', 'createTable tableName=label; createIndex indexName=idx_label_slug, tableName=label; createTable tableName=card_label; addUniqueConstraint constraintName=unique_card_label_card_id_label_id, tableName=card_label; createIndex indexName=idx_card_label...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::32::agilliland
CREATE TABLE metabase.raw_table (id SERIAL NOT NULL, database_id INTEGER NOT NULL, active BOOLEAN NOT NULL, schema VARCHAR(255), name VARCHAR(255) NOT NULL, details TEXT NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT RAW_TABLE_PKEY PRIMARY KEY (id), CONSTRAINT fk_rawtable_ref_database FOREIGN KEY (database_id) REFERENCES metabase.metabase_database(id));

CREATE INDEX idx_rawtable_database_id ON metabase.raw_table(database_id);

ALTER TABLE metabase.raw_table ADD CONSTRAINT uniq_raw_table_db_schema_name UNIQUE (database_id, schema, name);

CREATE TABLE metabase.raw_column (id SERIAL NOT NULL, raw_table_id INTEGER NOT NULL, active BOOLEAN NOT NULL, name VARCHAR(255) NOT NULL, column_type VARCHAR(128), is_pk BOOLEAN NOT NULL, fk_target_column_id INTEGER, details TEXT NOT NULL, created_at TIMESTAMP WITH TIME ZONE NOT NULL, updated_at TIMESTAMP WITH TIME ZONE NOT NULL, CONSTRAINT RAW_COLUMN_PKEY PRIMARY KEY (id), CONSTRAINT fk_rawcolumn_fktarget_ref_rawcolumn FOREIGN KEY (fk_target_column_id) REFERENCES metabase.raw_column(id), CONSTRAINT fk_rawcolumn_tableid_ref_rawtable FOREIGN KEY (raw_table_id) REFERENCES metabase.raw_table(id));

CREATE INDEX idx_rawcolumn_raw_table_id ON metabase.raw_column(raw_table_id);

ALTER TABLE metabase.raw_column ADD CONSTRAINT uniq_raw_column_table_name UNIQUE (raw_table_id, name);

ALTER TABLE metabase.metabase_table ADD raw_table_id INTEGER;

ALTER TABLE metabase.metabase_field ADD raw_column_id INTEGER;

ALTER TABLE metabase.metabase_field ADD last_analyzed TIMESTAMP WITH TIME ZONE;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('32', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 32, '8:483c6c6c8e0a8d056f7b9112d0b0125c', 'createTable tableName=raw_table; createIndex indexName=idx_rawtable_database_id, tableName=raw_table; addUniqueConstraint constraintName=uniq_raw_table_db_schema_name, tableName=raw_table; createTable tableName=raw_column; createIndex indexName=id...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::34::tlrobinson
ALTER TABLE metabase.pulse_channel ADD enabled BOOLEAN DEFAULT TRUE NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('34', 'tlrobinson', 'migrations/000_migrations.yaml', NOW(), 33, '8:52b082600b05bbbc46bfe837d1f37a82', 'addColumn tableName=pulse_channel', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::35::agilliland
ALTER TABLE metabase.setting ALTER COLUMN value TYPE TEXT USING (value::TEXT);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('35', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 34, '8:91b72167fca724e6b6a94b64f886cf09', 'modifyDataType columnName=value, tableName=setting', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::36::agilliland
ALTER TABLE metabase.report_dashboard ADD parameters TEXT;

UPDATE metabase.report_dashboard SET parameters = '[]' WHERE parameters IS NULL;

ALTER TABLE metabase.report_dashboard ALTER COLUMN  parameters SET NOT NULL;

ALTER TABLE metabase.report_dashboardcard ADD parameter_mappings TEXT;

UPDATE metabase.report_dashboardcard SET parameter_mappings = '[]' WHERE parameter_mappings IS NULL;

ALTER TABLE metabase.report_dashboardcard ALTER COLUMN  parameter_mappings SET NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('36', 'agilliland', 'migrations/000_migrations.yaml', NOW(), 35, '8:252e08892449dceb16c3d91337bd9573', 'addColumn tableName=report_dashboard; addNotNullConstraint columnName=parameters, tableName=report_dashboard; addColumn tableName=report_dashboardcard; addNotNullConstraint columnName=parameter_mappings, tableName=report_dashboardcard', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::37::tlrobinson
ALTER TABLE metabase.query_queryexecution ADD query_hash INTEGER;

UPDATE metabase.query_queryexecution SET query_hash = '0' WHERE query_hash IS NULL;

ALTER TABLE metabase.query_queryexecution ALTER COLUMN  query_hash SET NOT NULL;

CREATE INDEX idx_query_queryexecution_query_hash ON metabase.query_queryexecution(query_hash);

CREATE INDEX idx_query_queryexecution_started_at ON metabase.query_queryexecution(started_at);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('37', 'tlrobinson', 'migrations/000_migrations.yaml', NOW(), 36, '8:07d959eff81777e5690e2920583cfe5f', 'addColumn tableName=query_queryexecution; addNotNullConstraint columnName=query_hash, tableName=query_queryexecution; createIndex indexName=idx_query_queryexecution_query_hash, tableName=query_queryexecution; createIndex indexName=idx_query_querye...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::38::camsaul
ALTER TABLE metabase.metabase_database ADD points_of_interest TEXT;

ALTER TABLE metabase.metabase_table ADD points_of_interest TEXT;

ALTER TABLE metabase.metabase_field ADD points_of_interest TEXT;

ALTER TABLE metabase.report_dashboard ADD points_of_interest TEXT;

ALTER TABLE metabase.metric ADD points_of_interest TEXT;

ALTER TABLE metabase.segment ADD points_of_interest TEXT;

ALTER TABLE metabase.metabase_database ADD caveats TEXT;

ALTER TABLE metabase.metabase_table ADD caveats TEXT;

ALTER TABLE metabase.metabase_field ADD caveats TEXT;

ALTER TABLE metabase.report_dashboard ADD caveats TEXT;

ALTER TABLE metabase.metric ADD caveats TEXT;

ALTER TABLE metabase.segment ADD caveats TEXT;

ALTER TABLE metabase.metric ADD how_is_this_calculated TEXT;

ALTER TABLE metabase.report_dashboard ADD show_in_getting_started BOOLEAN DEFAULT FALSE NOT NULL;

CREATE INDEX idx_report_dashboard_show_in_getting_started ON metabase.report_dashboard(show_in_getting_started);

ALTER TABLE metabase.metric ADD show_in_getting_started BOOLEAN DEFAULT FALSE NOT NULL;

CREATE INDEX idx_metric_show_in_getting_started ON metabase.metric(show_in_getting_started);

ALTER TABLE metabase.metabase_table ADD show_in_getting_started BOOLEAN DEFAULT FALSE NOT NULL;

CREATE INDEX idx_metabase_table_show_in_getting_started ON metabase.metabase_table(show_in_getting_started);

ALTER TABLE metabase.segment ADD show_in_getting_started BOOLEAN DEFAULT FALSE NOT NULL;

CREATE INDEX idx_segment_show_in_getting_started ON metabase.segment(show_in_getting_started);

CREATE TABLE metabase.metric_important_field (id SERIAL NOT NULL, metric_id INTEGER NOT NULL, field_id INTEGER NOT NULL, CONSTRAINT METRIC_IMPORTANT_FIELD_PKEY PRIMARY KEY (id), CONSTRAINT fk_metric_important_field_metric_id FOREIGN KEY (metric_id) REFERENCES metabase.metric(id), CONSTRAINT fk_metric_important_field_metabase_field_id FOREIGN KEY (field_id) REFERENCES metabase.metabase_field(id));

ALTER TABLE metabase.metric_important_field ADD CONSTRAINT unique_metric_important_field_metric_id_field_id UNIQUE (metric_id, field_id);

CREATE INDEX idx_metric_important_field_metric_id ON metabase.metric_important_field(metric_id);

CREATE INDEX idx_metric_important_field_field_id ON metabase.metric_important_field(field_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('38', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 37, '8:43604ab55179b50306eb39353e760b46', 'addColumn tableName=metabase_database; addColumn tableName=metabase_table; addColumn tableName=metabase_field; addColumn tableName=report_dashboard; addColumn tableName=metric; addColumn tableName=segment; addColumn tableName=metabase_database; ad...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::39::camsaul
ALTER TABLE metabase.core_user ADD google_auth BOOLEAN DEFAULT FALSE NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('39', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 38, '8:334adc22af5ded71ff27759b7a556951', 'addColumn tableName=core_user', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::40::camsaul
CREATE TABLE metabase.permissions_group (id SERIAL NOT NULL, name VARCHAR(255) NOT NULL, CONSTRAINT PERMISSIONS_GROUP_PKEY PRIMARY KEY (id), CONSTRAINT unique_permissions_group_name UNIQUE (name));

CREATE INDEX idx_permissions_group_name ON metabase.permissions_group(name);

CREATE TABLE metabase.permissions_group_membership (id SERIAL NOT NULL, user_id INTEGER NOT NULL, group_id INTEGER NOT NULL, CONSTRAINT PERMISSIONS_GROUP_MEMBERSHIP_PKEY PRIMARY KEY (id), CONSTRAINT fk_permissions_group_membership_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id), CONSTRAINT fk_permissions_group_group_id FOREIGN KEY (group_id) REFERENCES metabase.permissions_group(id));

ALTER TABLE metabase.permissions_group_membership ADD CONSTRAINT unique_permissions_group_membership_user_id_group_id UNIQUE (user_id, group_id);

CREATE INDEX idx_permissions_group_membership_group_id ON metabase.permissions_group_membership(group_id);

CREATE INDEX idx_permissions_group_membership_user_id ON metabase.permissions_group_membership(user_id);

CREATE INDEX idx_permissions_group_membership_group_id_user_id ON metabase.permissions_group_membership(group_id, user_id);

CREATE TABLE metabase.permissions (id SERIAL NOT NULL, object VARCHAR(254) NOT NULL, group_id INTEGER NOT NULL, CONSTRAINT PERMISSIONS_PKEY PRIMARY KEY (id), CONSTRAINT fk_permissions_group_id FOREIGN KEY (group_id) REFERENCES metabase.permissions_group(id));

CREATE INDEX idx_permissions_group_id ON metabase.permissions(group_id);

CREATE INDEX idx_permissions_object ON metabase.permissions(object);

CREATE INDEX idx_permissions_group_id_object ON metabase.permissions(group_id, object);

ALTER TABLE metabase.permissions ADD UNIQUE (group_id, object);

ALTER TABLE metabase.metabase_table ALTER COLUMN schema TYPE VARCHAR(254) USING (schema::VARCHAR(254));

CREATE INDEX idx_metabase_table_db_id_schema ON metabase.metabase_table(db_id, schema);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('40', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 39, '8:ee7f50a264d6cf8d891bd01241eebd2c', 'createTable tableName=permissions_group; createIndex indexName=idx_permissions_group_name, tableName=permissions_group; createTable tableName=permissions_group_membership; addUniqueConstraint constraintName=unique_permissions_group_membership_user...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::41::camsaul
ALTER TABLE metabase.metabase_field DROP COLUMN field_type;

ALTER TABLE metabase.metabase_field ALTER COLUMN  active SET DEFAULT TRUE;

ALTER TABLE metabase.metabase_field ALTER COLUMN  preview_display SET DEFAULT TRUE;

ALTER TABLE metabase.metabase_field ALTER COLUMN  position SET DEFAULT 0;

ALTER TABLE metabase.metabase_field ALTER COLUMN  visibility_type SET DEFAULT 'normal';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('41', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 40, '8:fae0855adf2f702f1133e32fc98d02a5', 'dropColumn columnName=field_type, tableName=metabase_field; addDefaultValue columnName=active, tableName=metabase_field; addDefaultValue columnName=preview_display, tableName=metabase_field; addDefaultValue columnName=position, tableName=metabase_...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::42::camsaul
ALTER TABLE metabase.query_queryexecution DROP CONSTRAINT fk_queryexecution_ref_query_id;

ALTER TABLE metabase.query_queryexecution DROP COLUMN query_id;

ALTER TABLE metabase.core_user DROP COLUMN is_staff;

ALTER TABLE metabase.metabase_database DROP COLUMN organization_id;

ALTER TABLE metabase.report_card DROP COLUMN organization_id;

ALTER TABLE metabase.report_dashboard DROP COLUMN organization_id;

DROP TABLE metabase.annotation_annotation;

DROP TABLE metabase.core_permissionsviolation;

DROP TABLE metabase.core_userorgperm;

DROP TABLE metabase.core_organization;

DROP TABLE metabase.metabase_foreignkey;

DROP TABLE metabase.metabase_tablesegment;

DROP TABLE metabase.query_query;

DROP TABLE metabase.report_dashboardsubscription;

DROP TABLE metabase.report_emailreport_recipients;

DROP TABLE metabase.report_emailreportexecutions;

DROP TABLE metabase.report_emailreport;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('42', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 41, '8:e32b3a1624fa289a6ee1f3f0a2dac1f6', 'dropForeignKeyConstraint baseTableName=query_queryexecution, constraintName=fk_queryexecution_ref_query_id; dropColumn columnName=query_id, tableName=query_queryexecution; dropColumn columnName=is_staff, tableName=core_user; dropColumn columnName=...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::43::camsaul
CREATE TABLE metabase.permissions_revision (id SERIAL NOT NULL, before TEXT NOT NULL, after TEXT NOT NULL, user_id INTEGER NOT NULL, created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, remark TEXT, CONSTRAINT PERMISSIONS_REVISION_PKEY PRIMARY KEY (id), CONSTRAINT fk_permissions_revision_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

COMMENT ON TABLE metabase.permissions_revision IS 'Used to keep track of changes made to permissions.';

COMMENT ON COLUMN metabase.permissions_revision.before IS 'Serialized JSON of the permissions before the changes.';

COMMENT ON COLUMN metabase.permissions_revision.after IS 'Serialized JSON of the permissions after the changes.';

COMMENT ON COLUMN metabase.permissions_revision.user_id IS 'The ID of the admin who made this set of changes.';

COMMENT ON COLUMN metabase.permissions_revision.created_at IS 'The timestamp of when these changes were made.';

COMMENT ON COLUMN metabase.permissions_revision.remark IS 'Optional remarks explaining why these changes were made.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('43', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 42, '8:165e9384e46d6f9c0330784955363f70', 'createTable tableName=permissions_revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::44::camsaul
ALTER TABLE metabase.report_card DROP COLUMN public_perms;

ALTER TABLE metabase.report_dashboard DROP COLUMN public_perms;

ALTER TABLE metabase.pulse DROP COLUMN public_perms;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('44', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 43, '8:2e356e8a1049286f1c78324828ee7867', 'dropColumn columnName=public_perms, tableName=report_card; dropColumn columnName=public_perms, tableName=report_dashboard; dropColumn columnName=public_perms, tableName=pulse', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::45::tlrobinson
ALTER TABLE metabase.report_dashboardcard ADD visualization_settings TEXT;

UPDATE metabase.report_dashboardcard SET visualization_settings = '{}' WHERE visualization_settings IS NULL;

ALTER TABLE metabase.report_dashboardcard ALTER COLUMN  visualization_settings SET NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('45', 'tlrobinson', 'migrations/000_migrations.yaml', NOW(), 44, '8:421edd38ee0cb0983162f57193f81b0b', 'addColumn tableName=report_dashboardcard; addNotNullConstraint columnName=visualization_settings, tableName=report_dashboardcard', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::46::camsaul
UPDATE metabase.report_dashboardcard SET row = '0' WHERE row IS NULL;

ALTER TABLE metabase.report_dashboardcard ALTER COLUMN  row SET NOT NULL;

UPDATE metabase.report_dashboardcard SET col = '0' WHERE col IS NULL;

ALTER TABLE metabase.report_dashboardcard ALTER COLUMN  col SET NOT NULL;

ALTER TABLE metabase.report_dashboardcard ALTER COLUMN  row SET DEFAULT 0;

ALTER TABLE metabase.report_dashboardcard ALTER COLUMN  col SET DEFAULT 0;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('46', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 45, '8:131df3cdd9a8c67b32c5988a3fb7fe3d', 'addNotNullConstraint columnName=row, tableName=report_dashboardcard; addNotNullConstraint columnName=col, tableName=report_dashboardcard; addDefaultValue columnName=row, tableName=report_dashboardcard; addDefaultValue columnName=col, tableName=rep...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::47::camsaul
CREATE TABLE metabase.collection (id SERIAL NOT NULL, name TEXT NOT NULL, slug VARCHAR(254) NOT NULL, description TEXT, color CHAR(7) NOT NULL, archived BOOLEAN DEFAULT FALSE NOT NULL, CONSTRAINT COLLECTION_PKEY PRIMARY KEY (id), UNIQUE (slug));

COMMENT ON TABLE metabase.collection IS 'Collections are an optional way to organize Cards and handle permissions for them.';

COMMENT ON COLUMN metabase.collection.name IS 'The unique, user-facing name of this Collection.';

COMMENT ON COLUMN metabase.collection.slug IS 'URL-friendly, sluggified, indexed version of name.';

COMMENT ON COLUMN metabase.collection.description IS 'Optional description for this Collection.';

COMMENT ON COLUMN metabase.collection.color IS 'Seven-character hex color for this Collection, including the preceding hash sign.';

COMMENT ON COLUMN metabase.collection.archived IS 'Whether this Collection has been archived and should be hidden from users.';

CREATE INDEX idx_collection_slug ON metabase.collection(slug);

ALTER TABLE metabase.report_card ADD collection_id INTEGER;

ALTER TABLE metabase.report_card ADD CONSTRAINT fk_card_collection_id FOREIGN KEY (collection_id) REFERENCES metabase.collection (id);

COMMENT ON COLUMN metabase.report_card.collection_id IS 'Optional ID of Collection this Card belongs to.';

CREATE INDEX idx_card_collection_id ON metabase.report_card(collection_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('47', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 46, '8:1d2474e49a27db344c250872df58a6ed', 'createTable tableName=collection; createIndex indexName=idx_collection_slug, tableName=collection; addColumn tableName=report_card; createIndex indexName=idx_card_collection_id, tableName=report_card', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::48::camsaul
CREATE TABLE metabase.collection_revision (id SERIAL NOT NULL, before TEXT NOT NULL, after TEXT NOT NULL, user_id INTEGER NOT NULL, created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, remark TEXT, CONSTRAINT COLLECTION_REVISION_PKEY PRIMARY KEY (id), CONSTRAINT fk_collection_revision_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id));

COMMENT ON TABLE metabase.collection_revision IS 'Used to keep track of changes made to collections.';

COMMENT ON COLUMN metabase.collection_revision.before IS 'Serialized JSON of the collections graph before the changes.';

COMMENT ON COLUMN metabase.collection_revision.after IS 'Serialized JSON of the collections graph after the changes.';

COMMENT ON COLUMN metabase.collection_revision.user_id IS 'The ID of the admin who made this set of changes.';

COMMENT ON COLUMN metabase.collection_revision.created_at IS 'The timestamp of when these changes were made.';

COMMENT ON COLUMN metabase.collection_revision.remark IS 'Optional remarks explaining why these changes were made.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('48', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 47, '8:720ce9d4b9e6f0917aea035e9dc5d95d', 'createTable tableName=collection_revision', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::49::camsaul
ALTER TABLE metabase.report_card ADD public_uuid CHAR(36);

ALTER TABLE metabase.report_card ADD UNIQUE (public_uuid);

ALTER TABLE metabase.report_card ADD made_public_by_id INTEGER;

ALTER TABLE metabase.report_card ADD CONSTRAINT fk_card_made_public_by_id FOREIGN KEY (made_public_by_id) REFERENCES metabase.core_user (id);

COMMENT ON COLUMN metabase.report_card.public_uuid IS 'Unique UUID used to in publically-accessible links to this Card.';

COMMENT ON COLUMN metabase.report_card.made_public_by_id IS 'The ID of the User who first publically shared this Card.';

CREATE INDEX idx_card_public_uuid ON metabase.report_card(public_uuid);

ALTER TABLE metabase.report_dashboard ADD public_uuid CHAR(36);

ALTER TABLE metabase.report_dashboard ADD UNIQUE (public_uuid);

ALTER TABLE metabase.report_dashboard ADD made_public_by_id INTEGER;

ALTER TABLE metabase.report_dashboard ADD CONSTRAINT fk_dashboard_made_public_by_id FOREIGN KEY (made_public_by_id) REFERENCES metabase.core_user (id);

COMMENT ON COLUMN metabase.report_dashboard.public_uuid IS 'Unique UUID used to in publically-accessible links to this Dashboard.';

COMMENT ON COLUMN metabase.report_dashboard.made_public_by_id IS 'The ID of the User who first publically shared this Dashboard.';

CREATE INDEX idx_dashboard_public_uuid ON metabase.report_dashboard(public_uuid);

ALTER TABLE metabase.query_queryexecution ALTER COLUMN  executor_id DROP NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('49', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 48, '8:56dcab086b21de1df002561efeac8bb6', 'addColumn tableName=report_card; createIndex indexName=idx_card_public_uuid, tableName=report_card; addColumn tableName=report_dashboard; createIndex indexName=idx_dashboard_public_uuid, tableName=report_dashboard; dropNotNullConstraint columnName...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::50::camsaul
ALTER TABLE metabase.report_card ADD enable_embedding BOOLEAN DEFAULT FALSE NOT NULL;

ALTER TABLE metabase.report_card ADD embedding_params TEXT;

COMMENT ON COLUMN metabase.report_card.enable_embedding IS 'Is this Card allowed to be embedded in different websites (using a signed JWT)?';

COMMENT ON COLUMN metabase.report_card.embedding_params IS 'Serialized JSON containing information about required parameters that must be supplied when embedding this Card.';

ALTER TABLE metabase.report_dashboard ADD enable_embedding BOOLEAN DEFAULT FALSE NOT NULL;

ALTER TABLE metabase.report_dashboard ADD embedding_params TEXT;

COMMENT ON COLUMN metabase.report_dashboard.enable_embedding IS 'Is this Dashboard allowed to be embedded in different websites (using a signed JWT)?';

COMMENT ON COLUMN metabase.report_dashboard.embedding_params IS 'Serialized JSON containing information about required parameters that must be supplied when embedding this Dashboard.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('50', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 49, '8:388da4c48984aad647709514e4ba9204', 'addColumn tableName=report_card; addColumn tableName=report_dashboard', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::51::camsaul
CREATE TABLE metabase.query_execution (id SERIAL NOT NULL, hash BYTEA NOT NULL, started_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, running_time INTEGER NOT NULL, result_rows INTEGER NOT NULL, native BOOLEAN NOT NULL, context VARCHAR(32), error TEXT, executor_id INTEGER, card_id INTEGER, dashboard_id INTEGER, pulse_id INTEGER, CONSTRAINT QUERY_EXECUTION_PKEY PRIMARY KEY (id));

COMMENT ON TABLE metabase.query_execution IS 'A log of executed queries, used for calculating historic execution times, auditing, and other purposes.';

COMMENT ON COLUMN metabase.query_execution.hash IS 'The hash of the query dictionary. This is a 256-bit SHA3 hash of the query.';

COMMENT ON COLUMN metabase.query_execution.started_at IS 'Timestamp of when this query started running.';

COMMENT ON COLUMN metabase.query_execution.running_time IS 'The time, in milliseconds, this query took to complete.';

COMMENT ON COLUMN metabase.query_execution.result_rows IS 'Number of rows in the query results.';

COMMENT ON COLUMN metabase.query_execution.native IS 'Whether the query was a native query, as opposed to an MBQL one (e.g., created with the GUI).';

COMMENT ON COLUMN metabase.query_execution.context IS 'Short string specifying how this query was executed, e.g. in a Dashboard or Pulse.';

COMMENT ON COLUMN metabase.query_execution.error IS 'Error message returned by failed query, if any.';

COMMENT ON COLUMN metabase.query_execution.executor_id IS 'The ID of the User who triggered this query execution, if any.';

COMMENT ON COLUMN metabase.query_execution.card_id IS 'The ID of the Card (Question) associated with this query execution, if any.';

COMMENT ON COLUMN metabase.query_execution.dashboard_id IS 'The ID of the Dashboard associated with this query execution, if any.';

COMMENT ON COLUMN metabase.query_execution.pulse_id IS 'The ID of the Pulse associated with this query execution, if any.';

CREATE INDEX idx_query_execution_started_at ON metabase.query_execution(started_at);

CREATE INDEX idx_query_execution_query_hash_started_at ON metabase.query_execution(hash, started_at);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('51', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 50, '8:43c90b5b9f6c14bfd0e41cc0b184617e', 'createTable tableName=query_execution; createIndex indexName=idx_query_execution_started_at, tableName=query_execution; createIndex indexName=idx_query_execution_query_hash_started_at, tableName=query_execution', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::52::camsaul
CREATE TABLE metabase.query_cache (query_hash BYTEA NOT NULL, updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, results BYTEA NOT NULL, CONSTRAINT QUERY_CACHE_PKEY PRIMARY KEY (query_hash));

COMMENT ON TABLE metabase.query_cache IS 'Cached results of queries are stored here when using the DB-based query cache.';

COMMENT ON COLUMN metabase.query_cache.query_hash IS 'The hash of the query dictionary. (This is a 256-bit SHA3 hash of the query dict).';

COMMENT ON COLUMN metabase.query_cache.updated_at IS 'The timestamp of when these query results were last refreshed.';

COMMENT ON COLUMN metabase.query_cache.results IS 'Cached, compressed results of running the query with the given hash.';

CREATE INDEX idx_query_cache_updated_at ON metabase.query_cache(updated_at);

ALTER TABLE metabase.report_card ADD cache_ttl INTEGER;

COMMENT ON COLUMN metabase.report_card.cache_ttl IS 'The maximum time, in seconds, to return cached results for this Card rather than running a new query.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('52', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 51, '8:5af9ea2a96cd6e75a8ac1e6afde7126b', 'createTable tableName=query_cache; createIndex indexName=idx_query_cache_updated_at, tableName=query_cache; addColumn tableName=report_card', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::53::camsaul
CREATE TABLE metabase.query (query_hash BYTEA NOT NULL, average_execution_time INTEGER NOT NULL, CONSTRAINT QUERY_PKEY PRIMARY KEY (query_hash));

COMMENT ON TABLE metabase.query IS 'Information (such as average execution time) for different queries that have been previously ran.';

COMMENT ON COLUMN metabase.query.query_hash IS 'The hash of the query dictionary. (This is a 256-bit SHA3 hash of the query dict.)';

COMMENT ON COLUMN metabase.query.average_execution_time IS 'Average execution time for the query, round to nearest number of milliseconds. This is updated as a rolling average.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('53', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 52, '8:78d015c5090c57cd6972eb435601d3d0', 'createTable tableName=query', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::54::tlrobinson
ALTER TABLE metabase.pulse ADD skip_if_empty BOOLEAN DEFAULT FALSE NOT NULL;

COMMENT ON COLUMN metabase.pulse.skip_if_empty IS 'Skip a scheduled Pulse if none of its questions have any results';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('54', 'tlrobinson', 'migrations/000_migrations.yaml', NOW(), 53, '8:e410005b585f5eeb5f202076ff9468f7', 'addColumn tableName=pulse', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::55::camsaul
ALTER TABLE metabase.report_dashboard ADD archived BOOLEAN DEFAULT FALSE NOT NULL;

ALTER TABLE metabase.report_dashboard ADD position INTEGER;

COMMENT ON COLUMN metabase.report_dashboard.archived IS 'Is this Dashboard archived (effectively treated as deleted?)';

COMMENT ON COLUMN metabase.report_dashboard.position IS 'The position this Dashboard should appear in the Dashboards list, lower-numbered positions appearing before higher numbered ones.';

CREATE TABLE metabase.dashboard_favorite (id SERIAL NOT NULL, user_id INTEGER NOT NULL, dashboard_id INTEGER NOT NULL, CONSTRAINT DASHBOARD_FAVORITE_PKEY PRIMARY KEY (id), CONSTRAINT fk_dashboard_favorite_dashboard_id FOREIGN KEY (dashboard_id) REFERENCES metabase.report_dashboard(id) ON DELETE CASCADE, CONSTRAINT fk_dashboard_favorite_user_id FOREIGN KEY (user_id) REFERENCES metabase.core_user(id) ON DELETE CASCADE);

COMMENT ON TABLE metabase.dashboard_favorite IS 'Presence of a row here indicates a given User has favorited a given Dashboard.';

COMMENT ON COLUMN metabase.dashboard_favorite.user_id IS 'ID of the User who favorited the Dashboard.';

COMMENT ON COLUMN metabase.dashboard_favorite.dashboard_id IS 'ID of the Dashboard favorited by the User.';

ALTER TABLE metabase.dashboard_favorite ADD CONSTRAINT unique_dashboard_favorite_user_id_dashboard_id UNIQUE (user_id, dashboard_id);

CREATE INDEX idx_dashboard_favorite_user_id ON metabase.dashboard_favorite(user_id);

CREATE INDEX idx_dashboard_favorite_dashboard_id ON metabase.dashboard_favorite(dashboard_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('55', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 54, '8:87c4becde5fe208ba2c356128df86fba', 'addColumn tableName=report_dashboard; createTable tableName=dashboard_favorite; addUniqueConstraint constraintName=unique_dashboard_favorite_user_id_dashboard_id, tableName=dashboard_favorite; createIndex indexName=idx_dashboard_favorite_user_id, ...', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::56::wwwiiilll
-- Added 0.25.0
ALTER TABLE metabase.core_user ADD ldap_auth BOOLEAN DEFAULT FALSE NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('56', 'wwwiiilll', 'migrations/000_migrations.yaml', NOW(), 55, '8:9f46051abaee599e2838733512a32ad0', 'addColumn tableName=core_user', 'Added 0.25.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::57::camsaul
-- Added 0.25.0
ALTER TABLE metabase.report_card ADD result_metadata TEXT;

COMMENT ON COLUMN metabase.report_card.result_metadata IS 'Serialized JSON containing metadata about the result columns from running the query.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('57', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 56, '8:aab81d477e2d19a9ab18c58b78c9af88', 'addColumn tableName=report_card', 'Added 0.25.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::58::senior
-- Added 0.25.0
CREATE TABLE metabase.dimension (id SERIAL NOT NULL, field_id INTEGER NOT NULL, name VARCHAR(254) NOT NULL, type VARCHAR(254) NOT NULL, human_readable_field_id INTEGER, created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, CONSTRAINT DIMENSION_PKEY PRIMARY KEY (id), CONSTRAINT fk_dimension_displayfk_ref_field_id FOREIGN KEY (human_readable_field_id) REFERENCES metabase.metabase_field(id) ON DELETE CASCADE, CONSTRAINT fk_dimension_ref_field_id FOREIGN KEY (field_id) REFERENCES metabase.metabase_field(id) ON DELETE CASCADE);

COMMENT ON TABLE metabase.dimension IS 'Stores references to alternate views of existing fields, such as remapping an integer to a description, like an enum';

COMMENT ON COLUMN metabase.dimension.field_id IS 'ID of the field this dimension row applies to';

COMMENT ON COLUMN metabase.dimension.name IS 'Short description used as the display name of this new column';

COMMENT ON COLUMN metabase.dimension.type IS 'Either internal for a user defined remapping or external for a foreign key based remapping';

COMMENT ON COLUMN metabase.dimension.human_readable_field_id IS 'Only used with external type remappings. Indicates which field on the FK related table to use for display';

COMMENT ON COLUMN metabase.dimension.created_at IS 'The timestamp of when the dimension was created.';

COMMENT ON COLUMN metabase.dimension.updated_at IS 'The timestamp of when these dimension was last updated.';

ALTER TABLE metabase.dimension ADD CONSTRAINT unique_dimension_field_id_name UNIQUE (field_id, name);

CREATE INDEX idx_dimension_field_id ON metabase.dimension(field_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('58', 'senior', 'migrations/000_migrations.yaml', NOW(), 57, '8:3554219ca39e0fd682d0fba57531e917', 'createTable tableName=dimension; addUniqueConstraint constraintName=unique_dimension_field_id_name, tableName=dimension; createIndex indexName=idx_dimension_field_id, tableName=dimension', 'Added 0.25.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::59::camsaul
-- Added 0.26.0
ALTER TABLE metabase.metabase_field ADD fingerprint TEXT;

COMMENT ON COLUMN metabase.metabase_field.fingerprint IS 'Serialized JSON containing non-identifying information about this Field, such as min, max, and percent JSON. Used for classification.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('59', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 58, '8:5b6ce52371e0e9eee88e6d766225a94b', 'addColumn tableName=metabase_field', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::60::camsaul
-- Added 0.26.0
ALTER TABLE metabase.metabase_database ADD metadata_sync_schedule VARCHAR(254) DEFAULT '0 50 * * * ? *' NOT NULL;

ALTER TABLE metabase.metabase_database ADD cache_field_values_schedule VARCHAR(254) DEFAULT '0 50 0 * * ? *' NOT NULL;

COMMENT ON COLUMN metabase.metabase_database.metadata_sync_schedule IS 'The cron schedule string for when this database should undergo the metadata sync process (and analysis for new fields).';

COMMENT ON COLUMN metabase.metabase_database.cache_field_values_schedule IS 'The cron schedule string for when FieldValues for eligible Fields should be updated.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('60', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 59, '8:4f997b2cd3309882e900493892381f38', 'addColumn tableName=metabase_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::61::camsaul
-- Added 0.26.0
ALTER TABLE metabase.metabase_field ADD fingerprint_version INTEGER DEFAULT 0 NOT NULL;

COMMENT ON COLUMN metabase.metabase_field.fingerprint_version IS 'The version of the fingerprint for this Field. Used so we can keep track of which Fields need to be analyzed again when new things are added to fingerprints.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('61', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 60, '8:7dded6fd5bf74d79b9a0b62511981272', 'addColumn tableName=metabase_field', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::62::senior
-- Added 0.26.0
ALTER TABLE metabase.metabase_database ADD timezone VARCHAR(254);

COMMENT ON COLUMN metabase.metabase_database.timezone IS 'Timezone identifier for the database, set by the sync process';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('62', 'senior', 'migrations/000_migrations.yaml', NOW(), 61, '8:cb32e6eaa1a2140703def2730f81fef2', 'addColumn tableName=metabase_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::63::camsaul
-- Added 0.26.0
ALTER TABLE metabase.metabase_database ADD is_on_demand BOOLEAN DEFAULT FALSE NOT NULL;

COMMENT ON COLUMN metabase.metabase_database.is_on_demand IS 'Whether we should do On-Demand caching of FieldValues for this DB. This means FieldValues are updated when their Field is used in a Dashboard or Card param.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('63', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 62, '8:226f73b9f6617495892d281b0f8303db', 'addColumn tableName=metabase_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::64::senior
-- Added 0.26.0
ALTER TABLE metabase.raw_table DROP CONSTRAINT fk_rawtable_ref_database;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('64', 'senior', 'migrations/000_migrations.yaml', NOW(), 63, '8:4dcc8ffd836b56756f494d5dfce07b50', 'dropForeignKeyConstraint baseTableName=raw_table, constraintName=fk_rawtable_ref_database', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::66::senior
-- Added 0.26.0
drop table if exists computation_job_result cascade;

drop table if exists computation_job cascade;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('66', 'senior', 'migrations/000_migrations.yaml', NOW(), 64, '8:e77d66af8e3b83d46c5a0064a75a1aac', 'sql; sql', 'Added 0.26.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::67::attekei
-- Added 0.27.0
CREATE TABLE metabase.computation_job (id SERIAL NOT NULL, creator_id INTEGER, created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, type VARCHAR(254) NOT NULL, status VARCHAR(254) NOT NULL, CONSTRAINT COMPUTATION_JOB_PKEY PRIMARY KEY (id), CONSTRAINT fk_computation_job_ref_user_id FOREIGN KEY (creator_id) REFERENCES metabase.core_user(id));

COMMENT ON TABLE metabase.computation_job IS 'Stores submitted async computation jobs.';

CREATE TABLE metabase.computation_job_result (id SERIAL NOT NULL, job_id INTEGER NOT NULL, created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, permanence VARCHAR(254) NOT NULL, payload TEXT NOT NULL, CONSTRAINT COMPUTATION_JOB_RESULT_PKEY PRIMARY KEY (id), CONSTRAINT fk_computation_result_ref_job_id FOREIGN KEY (job_id) REFERENCES metabase.computation_job(id));

COMMENT ON TABLE metabase.computation_job_result IS 'Stores results of async computation jobs.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('67', 'attekei', 'migrations/000_migrations.yaml', NOW(), 65, '8:59dfc37744fc362e0e312488fbc9a69b', 'createTable tableName=computation_job; createTable tableName=computation_job_result', 'Added 0.27.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::68::sbelak
-- Added 0.27.0
ALTER TABLE metabase.computation_job ADD context TEXT;

ALTER TABLE metabase.computation_job ADD ended_at TIMESTAMP WITHOUT TIME ZONE;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('68', 'sbelak', 'migrations/000_migrations.yaml', NOW(), 66, '8:ca201aeb20c1719a46c6bcc3fc95c81d', 'addColumn tableName=computation_job', 'Added 0.27.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::69::senior
-- Added 0.27.0
ALTER TABLE metabase.pulse ADD alert_condition VARCHAR(254);

ALTER TABLE metabase.pulse ADD alert_first_only BOOLEAN;

ALTER TABLE metabase.pulse ADD alert_above_goal BOOLEAN;

COMMENT ON COLUMN metabase.pulse.alert_condition IS 'Condition (i.e. "rows" or "goal") used as a guard for alerts';

COMMENT ON COLUMN metabase.pulse.alert_first_only IS 'True if the alert should be disabled after the first notification';

COMMENT ON COLUMN metabase.pulse.alert_above_goal IS 'For a goal condition, alert when above the goal';

ALTER TABLE metabase.pulse ALTER COLUMN  name DROP NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('69', 'senior', 'migrations/000_migrations.yaml', NOW(), 67, '8:97b7768436b9e8d695bae984020d754c', 'addColumn tableName=pulse; dropNotNullConstraint columnName=name, tableName=pulse', 'Added 0.27.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::70::camsaul
-- Added 0.28.0
ALTER TABLE metabase.metabase_field ADD database_type VARCHAR(255);

COMMENT ON COLUMN metabase.metabase_field.database_type IS 'The actual type of this column in the database. e.g. VARCHAR or TEXT.';

UPDATE metabase.metabase_field SET database_type = '?' WHERE database_type IS NULL;

ALTER TABLE metabase.metabase_field ALTER COLUMN  database_type SET NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('70', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 68, '8:4e4eff7abb983b1127a32ba8107e7fb8', 'addColumn tableName=metabase_field; addNotNullConstraint columnName=database_type, tableName=metabase_field', 'Added 0.28.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::71::camsaul
-- Added 0.28.0
ALTER TABLE metabase.report_dashboardcard ALTER COLUMN  card_id DROP NOT NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('71', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 69, '8:755e5c3dd8a55793f29b2c95cb79c211', 'dropNotNullConstraint columnName=card_id, tableName=report_dashboardcard', 'Added 0.28.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::72::senior
-- Added 0.28.0
ALTER TABLE metabase.pulse_card ADD include_csv BOOLEAN DEFAULT FALSE NOT NULL;

ALTER TABLE metabase.pulse_card ADD include_xls BOOLEAN DEFAULT FALSE NOT NULL;

COMMENT ON COLUMN metabase.pulse_card.include_csv IS 'True if a CSV of the data should be included for this pulse card';

COMMENT ON COLUMN metabase.pulse_card.include_xls IS 'True if a XLS of the data should be included for this pulse card';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('72', 'senior', 'migrations/000_migrations.yaml', NOW(), 70, '8:ed16046dfa04c139f48e9068eb4faee4', 'addColumn tableName=pulse_card', 'Added 0.28.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::73::camsaul
-- Added 0.29.0
ALTER TABLE metabase.metabase_database ADD options TEXT;

COMMENT ON COLUMN metabase.metabase_database.options IS 'Serialized JSON containing various options like QB behavior.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('73', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 71, '8:3c0f03d18ff78a0bcc9915e1d9c518d6', 'addColumn tableName=metabase_database', 'Added 0.29.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::74::camsaul
-- Added 0.29.0
ALTER TABLE metabase.metabase_field ADD has_field_values TEXT;

COMMENT ON COLUMN metabase.metabase_field.has_field_values IS 'Whether we have FieldValues ("list"), should ad-hoc search ("search"), disable entirely ("none"), or infer dynamically (null)"';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('74', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 72, '8:16726d6560851325930c25caf3c8ab96', 'addColumn tableName=metabase_field', 'Added 0.29.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::75::camsaul
-- Added 0.28.2
ALTER TABLE metabase.report_card ADD read_permissions TEXT;

COMMENT ON COLUMN metabase.report_card.read_permissions IS 'Permissions required to view this Card and run its query.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('75', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 73, '8:6072cabfe8188872d8e3da9a675f88c1', 'addColumn tableName=report_card', 'Added 0.28.2', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::76::senior
-- Added 0.30.0
ALTER TABLE metabase.metabase_table ADD fields_hash TEXT;

COMMENT ON COLUMN metabase.metabase_table.fields_hash IS 'Computed hash of all of the fields associated to this table';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('76', 'senior', 'migrations/000_migrations.yaml', NOW(), 74, '8:9b7190c9171ccca72617d508875c3c82', 'addColumn tableName=metabase_table', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::77::senior
-- Added 0.30.0
ALTER TABLE metabase.core_user ADD login_attributes TEXT;

COMMENT ON COLUMN metabase.core_user.login_attributes IS 'JSON serialized map with attributes used for row level permissions';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('77', 'senior', 'migrations/000_migrations.yaml', NOW(), 75, '8:07f0a6cd8dbbd9b89be0bd7378f7bdc8', 'addColumn tableName=core_user', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::79::camsaul
-- Added 0.30.0
ALTER TABLE metabase.report_dashboard ADD collection_id INTEGER;

ALTER TABLE metabase.report_dashboard ADD CONSTRAINT fk_dashboard_collection_id FOREIGN KEY (collection_id) REFERENCES metabase.collection (id);

COMMENT ON COLUMN metabase.report_dashboard.collection_id IS 'Optional ID of Collection this Dashboard belongs to.';

CREATE INDEX idx_dashboard_collection_id ON metabase.report_dashboard(collection_id);

ALTER TABLE metabase.pulse ADD collection_id INTEGER;

ALTER TABLE metabase.pulse ADD CONSTRAINT fk_pulse_collection_id FOREIGN KEY (collection_id) REFERENCES metabase.collection (id);

COMMENT ON COLUMN metabase.pulse.collection_id IS 'Options ID of Collection this Pulse belongs to.';

CREATE INDEX idx_pulse_collection_id ON metabase.pulse(collection_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('79', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 76, '8:3f31cb67f9cdf7754ca95cade22d87a2', 'addColumn tableName=report_dashboard; createIndex indexName=idx_dashboard_collection_id, tableName=report_dashboard; addColumn tableName=pulse; createIndex indexName=idx_pulse_collection_id, tableName=pulse', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::80::camsaul
ALTER TABLE metabase.collection ADD location VARCHAR(254) DEFAULT '/' NOT NULL;

COMMENT ON COLUMN metabase.collection.location IS 'Directory-structure path of ancestor Collections. e.g. "/1/2/" means our Parent is Collection 2, and their parent is Collection 1.';

CREATE INDEX idx_collection_location ON metabase.collection(location);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('80', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 77, '8:199d0ce28955117819ca15bcc29323e5', 'addColumn tableName=collection; createIndex indexName=idx_collection_location, tableName=collection', '', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::81::camsaul
-- Added 0.30.0
ALTER TABLE metabase.report_dashboard ADD collection_position SMALLINT;

COMMENT ON COLUMN metabase.report_dashboard.collection_position IS 'Optional pinned position for this item in its Collection. NULL means item is not pinned.';

ALTER TABLE metabase.report_card ADD collection_position SMALLINT;

COMMENT ON COLUMN metabase.report_card.collection_position IS 'Optional pinned position for this item in its Collection. NULL means item is not pinned.';

ALTER TABLE metabase.pulse ADD collection_position SMALLINT;

COMMENT ON COLUMN metabase.pulse.collection_position IS 'Optional pinned position for this item in its Collection. NULL means item is not pinned.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('81', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 78, '8:3a6dc22403660529194d004ca7f7ad39', 'addColumn tableName=report_dashboard; addColumn tableName=report_card; addColumn tableName=pulse', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::82::senior
-- Added 0.30.0
ALTER TABLE metabase.core_user ADD updated_at TIMESTAMP WITHOUT TIME ZONE;

COMMENT ON COLUMN metabase.core_user.updated_at IS 'When was this User last updated?';

update metabase.core_user set updated_at=date_joined;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('82', 'senior', 'migrations/000_migrations.yaml', NOW(), 79, '8:ac4b94df8c648f88cfff661284d6392d', 'addColumn tableName=core_user; sql', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::84::senior
-- Added 0.30.0
ALTER TABLE metabase.metric RENAME COLUMN is_active TO archived;

ALTER TABLE metabase.metric ALTER COLUMN  archived SET DEFAULT FALSE;

ALTER TABLE metabase.segment RENAME COLUMN is_active TO archived;

ALTER TABLE metabase.segment ALTER COLUMN  archived SET DEFAULT FALSE;

ALTER TABLE metabase.pulse ADD archived BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN metabase.pulse.archived IS 'Has this pulse been archived?';

update metabase.segment set archived = not(archived);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('84', 'senior', 'migrations/000_migrations.yaml', NOW(), 80, '8:58afc10c3e283a8050ea471aac447a97', 'renameColumn newColumnName=archived, oldColumnName=is_active, tableName=metric; addDefaultValue columnName=archived, tableName=metric; renameColumn newColumnName=archived, oldColumnName=is_active, tableName=segment; addDefaultValue columnName=arch...', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::85::camsaul
-- Added 0.30.0
ALTER TABLE metabase.collection ADD personal_owner_id INTEGER;

ALTER TABLE metabase.collection ADD CONSTRAINT unique_collection_personal_owner_id UNIQUE (personal_owner_id);

ALTER TABLE metabase.collection ADD CONSTRAINT fk_collection_personal_owner_id FOREIGN KEY (personal_owner_id) REFERENCES metabase.core_user (id);

COMMENT ON COLUMN metabase.collection.personal_owner_id IS 'If set, this Collection is a personal Collection, for exclusive use of the User with this ID.';

CREATE INDEX idx_collection_personal_owner_id ON metabase.collection(personal_owner_id);

ALTER TABLE metabase.collection ADD _slug VARCHAR(254);

COMMENT ON COLUMN metabase.collection._slug IS 'Sluggified version of the Collection name. Used only for display purposes in URL; not unique or indexed.';

UPDATE metabase.collection SET _slug = slug;

ALTER TABLE metabase.collection ALTER COLUMN  _slug SET NOT NULL;

ALTER TABLE metabase.collection DROP COLUMN slug;

ALTER TABLE metabase.collection RENAME COLUMN _slug TO slug;

COMMENT ON COLUMN metabase.collection.name IS 'The user-facing name of this Collection.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('85', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 81, '8:9b4c9878a5018452dd63eb6d7c17f415', 'addColumn tableName=collection; createIndex indexName=idx_collection_personal_owner_id, tableName=collection; addColumn tableName=collection; sql; addNotNullConstraint columnName=_slug, tableName=collection; dropColumn columnName=slug, tableName=c...', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::86::camsaul
-- Added 0.30.0
DELETE FROM metabase.permissions WHERE object LIKE '%/native/read/';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('86', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 82, '8:50c75bb29f479e0b3fb782d89f7d6717', 'sql', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::87::camsaul
-- Added 0.30.0
DROP TABLE metabase.raw_column;

DROP TABLE metabase.raw_table;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('87', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 83, '8:0eccf19a93cb0ba4017aafd1d308c097', 'dropTable tableName=raw_column; dropTable tableName=raw_table', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::89::camsaul
-- Added 0.30.0
CREATE TABLE metabase.QRTZ_JOB_DETAILS (SCHED_NAME VARCHAR(120) NOT NULL, JOB_NAME VARCHAR(200) NOT NULL, JOB_GROUP VARCHAR(200) NOT NULL, DESCRIPTION VARCHAR(250), JOB_CLASS_NAME VARCHAR(250) NOT NULL, IS_DURABLE BOOLEAN NOT NULL, IS_NONCONCURRENT BOOLEAN NOT NULL, IS_UPDATE_DATA BOOLEAN NOT NULL, REQUESTS_RECOVERY BOOLEAN NOT NULL, JOB_DATA BYTEA);

COMMENT ON TABLE metabase.QRTZ_JOB_DETAILS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_JOB_DETAILS ADD CONSTRAINT PK_QRTZ_JOB_DETAILS PRIMARY KEY (SCHED_NAME, JOB_NAME, JOB_GROUP);

CREATE TABLE metabase.QRTZ_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, JOB_NAME VARCHAR(200) NOT NULL, JOB_GROUP VARCHAR(200) NOT NULL, DESCRIPTION VARCHAR(250), NEXT_FIRE_TIME BIGINT, PREV_FIRE_TIME BIGINT, PRIORITY INTEGER, TRIGGER_STATE VARCHAR(16) NOT NULL, TRIGGER_TYPE VARCHAR(8) NOT NULL, START_TIME BIGINT NOT NULL, END_TIME BIGINT, CALENDAR_NAME VARCHAR(200), MISFIRE_INSTR SMALLINT, JOB_DATA BYTEA);

COMMENT ON TABLE metabase.QRTZ_TRIGGERS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_TRIGGERS ADD CONSTRAINT PK_QRTZ_TRIGGERS PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase.QRTZ_TRIGGERS ADD CONSTRAINT FK_QRTZ_TRIGGERS_JOB_DETAILS FOREIGN KEY (SCHED_NAME, JOB_NAME, JOB_GROUP) REFERENCES metabase.QRTZ_JOB_DETAILS (SCHED_NAME, JOB_NAME, JOB_GROUP);

CREATE TABLE metabase.QRTZ_SIMPLE_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, REPEAT_COUNT BIGINT NOT NULL, REPEAT_INTERVAL BIGINT NOT NULL, TIMES_TRIGGERED BIGINT NOT NULL);

COMMENT ON TABLE metabase.QRTZ_SIMPLE_TRIGGERS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_SIMPLE_TRIGGERS ADD CONSTRAINT PK_QRTZ_SIMPLE_TRIGGERS PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase.QRTZ_SIMPLE_TRIGGERS ADD CONSTRAINT FK_QRTZ_SIMPLE_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

CREATE TABLE metabase.QRTZ_CRON_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, CRON_EXPRESSION VARCHAR(120) NOT NULL, TIME_ZONE_ID VARCHAR(80));

COMMENT ON TABLE metabase.QRTZ_CRON_TRIGGERS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_CRON_TRIGGERS ADD CONSTRAINT PK_QRTZ_CRON_TRIGGERS PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase.QRTZ_CRON_TRIGGERS ADD CONSTRAINT FK_QRTZ_CRON_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

CREATE TABLE metabase.QRTZ_SIMPROP_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, STR_PROP_1 VARCHAR(512), STR_PROP_2 VARCHAR(512), STR_PROP_3 VARCHAR(512), INT_PROP_1 INTEGER, INT_PROP_2 INTEGER, LONG_PROP_1 BIGINT, LONG_PROP_2 BIGINT, DEC_PROP_1 numeric(13, 4), DEC_PROP_2 numeric(13, 4), BOOL_PROP_1 BOOLEAN, BOOL_PROP_2 BOOLEAN);

COMMENT ON TABLE metabase.QRTZ_SIMPROP_TRIGGERS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_SIMPROP_TRIGGERS ADD CONSTRAINT PK_QRTZ_SIMPROP_TRIGGERS PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase.QRTZ_SIMPROP_TRIGGERS ADD CONSTRAINT FK_QRTZ_SIMPROP_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

CREATE TABLE metabase.QRTZ_BLOB_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, BLOB_DATA BYTEA);

COMMENT ON TABLE metabase.QRTZ_BLOB_TRIGGERS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_BLOB_TRIGGERS ADD CONSTRAINT PK_QRTZ_BLOB_TRIGGERS PRIMARY KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

ALTER TABLE metabase.QRTZ_BLOB_TRIGGERS ADD CONSTRAINT FK_QRTZ_BLOB_TRIGGERS_TRIGGERS FOREIGN KEY (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP) REFERENCES metabase.QRTZ_TRIGGERS (SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

CREATE TABLE metabase.QRTZ_CALENDARS (SCHED_NAME VARCHAR(120) NOT NULL, CALENDAR_NAME VARCHAR(200) NOT NULL, CALENDAR BYTEA NOT NULL);

COMMENT ON TABLE metabase.QRTZ_CALENDARS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_CALENDARS ADD CONSTRAINT PK_QRTZ_CALENDARS PRIMARY KEY (SCHED_NAME, CALENDAR_NAME);

CREATE TABLE metabase.QRTZ_PAUSED_TRIGGER_GRPS (SCHED_NAME VARCHAR(120) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL);

COMMENT ON TABLE metabase.QRTZ_PAUSED_TRIGGER_GRPS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_PAUSED_TRIGGER_GRPS ADD CONSTRAINT PK_SCHED_NAME PRIMARY KEY (SCHED_NAME, TRIGGER_GROUP);

CREATE TABLE metabase.QRTZ_FIRED_TRIGGERS (SCHED_NAME VARCHAR(120) NOT NULL, ENTRY_ID VARCHAR(95) NOT NULL, TRIGGER_NAME VARCHAR(200) NOT NULL, TRIGGER_GROUP VARCHAR(200) NOT NULL, INSTANCE_NAME VARCHAR(200) NOT NULL, FIRED_TIME BIGINT NOT NULL, SCHED_TIME BIGINT, PRIORITY INTEGER NOT NULL, STATE VARCHAR(16) NOT NULL, JOB_NAME VARCHAR(200), JOB_GROUP VARCHAR(200), IS_NONCONCURRENT BOOLEAN, REQUESTS_RECOVERY BOOLEAN);

COMMENT ON TABLE metabase.QRTZ_FIRED_TRIGGERS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_FIRED_TRIGGERS ADD CONSTRAINT PK_QRTZ_FIRED_TRIGGERS PRIMARY KEY (SCHED_NAME, ENTRY_ID);

CREATE TABLE metabase.QRTZ_SCHEDULER_STATE (SCHED_NAME VARCHAR(120) NOT NULL, INSTANCE_NAME VARCHAR(200) NOT NULL, LAST_CHECKIN_TIME BIGINT NOT NULL, CHECKIN_INTERVAL BIGINT NOT NULL);

COMMENT ON TABLE metabase.QRTZ_SCHEDULER_STATE IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_SCHEDULER_STATE ADD CONSTRAINT PK_QRTZ_SCHEDULER_STATE PRIMARY KEY (SCHED_NAME, INSTANCE_NAME);

CREATE TABLE metabase.QRTZ_LOCKS (SCHED_NAME VARCHAR(120) NOT NULL, LOCK_NAME VARCHAR(40) NOT NULL);

COMMENT ON TABLE metabase.QRTZ_LOCKS IS 'Used for Quartz scheduler.';

ALTER TABLE metabase.QRTZ_LOCKS ADD CONSTRAINT PK_QRTZ_LOCKS PRIMARY KEY (SCHED_NAME, LOCK_NAME);

CREATE INDEX IDX_QRTZ_J_REQ_RECOVERY ON metabase.QRTZ_JOB_DETAILS(SCHED_NAME, REQUESTS_RECOVERY);

CREATE INDEX IDX_QRTZ_J_GRP ON metabase.QRTZ_JOB_DETAILS(SCHED_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_T_J ON metabase.QRTZ_TRIGGERS(SCHED_NAME, JOB_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_T_JG ON metabase.QRTZ_TRIGGERS(SCHED_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_T_C ON metabase.QRTZ_TRIGGERS(SCHED_NAME, CALENDAR_NAME);

CREATE INDEX IDX_QRTZ_T_G ON metabase.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_GROUP);

CREATE INDEX IDX_QRTZ_T_STATE ON metabase.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_N_STATE ON metabase.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_N_G_STATE ON metabase.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_GROUP, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_NEXT_FIRE_TIME ON metabase.QRTZ_TRIGGERS(SCHED_NAME, NEXT_FIRE_TIME);

CREATE INDEX IDX_QRTZ_T_NFT_ST ON metabase.QRTZ_TRIGGERS(SCHED_NAME, TRIGGER_STATE, NEXT_FIRE_TIME);

CREATE INDEX IDX_QRTZ_T_NFT_MISFIRE ON metabase.QRTZ_TRIGGERS(SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME);

CREATE INDEX IDX_QRTZ_T_NFT_ST_MISFIRE ON metabase.QRTZ_TRIGGERS(SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_T_NFT_ST_MISFIRE_GRP ON metabase.QRTZ_TRIGGERS(SCHED_NAME, MISFIRE_INSTR, NEXT_FIRE_TIME, TRIGGER_GROUP, TRIGGER_STATE);

CREATE INDEX IDX_QRTZ_FT_TRIG_INST_NAME ON metabase.QRTZ_FIRED_TRIGGERS(SCHED_NAME, INSTANCE_NAME);

CREATE INDEX IDX_QRTZ_FT_INST_JOB_REQ_RCVRY ON metabase.QRTZ_FIRED_TRIGGERS(SCHED_NAME, INSTANCE_NAME, REQUESTS_RECOVERY);

CREATE INDEX IDX_QRTZ_FT_J_G ON metabase.QRTZ_FIRED_TRIGGERS(SCHED_NAME, JOB_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_FT_JG ON metabase.QRTZ_FIRED_TRIGGERS(SCHED_NAME, JOB_GROUP);

CREATE INDEX IDX_QRTZ_FT_T_G ON metabase.QRTZ_FIRED_TRIGGERS(SCHED_NAME, TRIGGER_NAME, TRIGGER_GROUP);

CREATE INDEX IDX_QRTZ_FT_TG ON metabase.QRTZ_FIRED_TRIGGERS(SCHED_NAME, TRIGGER_GROUP);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('89', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 84, '8:94d5c406e3ec44e2bc85abe96f6fd91c', 'createTable tableName=QRTZ_JOB_DETAILS; addPrimaryKey constraintName=PK_QRTZ_JOB_DETAILS, tableName=QRTZ_JOB_DETAILS; createTable tableName=QRTZ_TRIGGERS; addPrimaryKey constraintName=PK_QRTZ_TRIGGERS, tableName=QRTZ_TRIGGERS; addForeignKeyConstra...', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::91::camsaul
-- Added 0.30.0
ALTER TABLE metabase.metabase_table DROP COLUMN raw_table_id;

ALTER TABLE metabase.metabase_field DROP COLUMN raw_column_id;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('91', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 85, '8:9b8831e1e409f08e874c4ece043d0340', 'dropColumn columnName=raw_table_id, tableName=metabase_table; dropColumn columnName=raw_column_id, tableName=metabase_field', 'Added 0.30.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::92::camsaul
-- Added 0.31.0
ALTER TABLE metabase.query_execution ADD database_id INTEGER;

COMMENT ON COLUMN metabase.query_execution.database_id IS 'ID of the database this query was ran against.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('92', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 86, '8:1e5bc2d66778316ea640a561862c23b4', 'addColumn tableName=query_execution', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::93::camsaul
-- Added 0.31.0
ALTER TABLE metabase.query ADD query TEXT;

COMMENT ON COLUMN metabase.query.query IS 'The actual "query dictionary" for this query.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('93', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 87, '8:93b0d408a3970e30d7184ed1166b5476', 'addColumn tableName=query', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::94::senior
-- Added 0.31.0
CREATE TABLE metabase.task_history (id SERIAL NOT NULL, task VARCHAR(254) NOT NULL, db_id INTEGER, started_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, ended_at TIMESTAMP WITHOUT TIME ZONE NOT NULL, duration INTEGER NOT NULL, task_details TEXT, CONSTRAINT TASK_HISTORY_PKEY PRIMARY KEY (id));

COMMENT ON TABLE metabase.task_history IS 'Timing and metadata info about background/quartz processes';

COMMENT ON COLUMN metabase.task_history.task IS 'Name of the task';

COMMENT ON COLUMN metabase.task_history.task_details IS 'JSON string with additional info on the task';

CREATE INDEX idx_task_history_end_time ON metabase.task_history(ended_at);

CREATE INDEX idx_task_history_db_id ON metabase.task_history(db_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('94', 'senior', 'migrations/000_migrations.yaml', NOW(), 88, '8:a2a1eedf1e8f8756856c9d49c7684bfe', 'createTable tableName=task_history; createIndex indexName=idx_task_history_end_time, tableName=task_history; createIndex indexName=idx_task_history_db_id, tableName=task_history', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::95::senior
-- Added 0.31.0
ALTER TABLE metabase.DATABASECHANGELOG ADD CONSTRAINT idx_databasechangelog_id_author_filename UNIQUE (id, author, filename);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('95', 'senior', 'migrations/000_migrations.yaml', NOW(), 89, '8:9824808283004e803003b938399a4cf0', 'addUniqueConstraint constraintName=idx_databasechangelog_id_author_filename, tableName=DATABASECHANGELOG', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::96::camsaul
-- Added 0.31.0
ALTER TABLE metabase.metabase_field ADD settings TEXT;

COMMENT ON COLUMN metabase.metabase_field.settings IS 'Serialized JSON FE-specific settings like formatting, etc. Scope of what is stored here may increase in future.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('96', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 90, '8:5cb2f36edcca9c6e14c5e109d6aeb68b', 'addColumn tableName=metabase_field', 'Added 0.31.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::97::senior
-- Added 0.32.0
ALTER TABLE metabase.query_cache ALTER COLUMN results TYPE BYTEA USING (results::BYTEA);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('97', 'senior', 'migrations/000_migrations.yaml', NOW(), 91, '8:9169e238663c5d036bd83428d2fa8e4b', 'modifyDataType columnName=results, tableName=query_cache', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::98::camsaul
-- Added 0.32.0
ALTER TABLE metabase.metabase_table ADD CONSTRAINT idx_uniq_table_db_id_schema_name UNIQUE (db_id, schema, name);

CREATE UNIQUE INDEX idx_uniq_table_db_id_schema_name_2col ON metabase.metabase_table ("db_id", "name") WHERE "schema" IS NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('98', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 92, '8:f036d20a4dc86fb60ffb64ea838ed6b9', 'addUniqueConstraint constraintName=idx_uniq_table_db_id_schema_name, tableName=metabase_table; sql', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::99::camsaul
-- Added 0.32.0
ALTER TABLE metabase.metabase_field ADD CONSTRAINT idx_uniq_field_table_id_parent_id_name UNIQUE (table_id, parent_id, name);

CREATE UNIQUE INDEX idx_uniq_field_table_id_parent_id_name_2col ON metabase.metabase_field ("table_id", "name") WHERE "parent_id" IS NULL;

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('99', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 93, '8:274bb516dd95b76c954b26084eed1dfe', 'addUniqueConstraint constraintName=idx_uniq_field_table_id_parent_id_name, tableName=metabase_field; sql', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::100::camsaul
-- Added 0.32.0
UPDATE metabase.metric SET archived = NOT archived WHERE EXISTS (
  SELECT *
  FROM metabase.databasechangelog dbcl
  WHERE dbcl.id = '84'
    AND metric.updated_at < dbcl.dateexecuted
);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('100', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 94, '8:948014f13b6198b50e3b7a066fae2ae0', 'sql', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::101::camsaul
-- Added 0.32.0
CREATE INDEX idx_field_parent_id ON metabase.metabase_field(parent_id);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('101', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 95, '8:58eabb08a175fafe8985208545374675', 'createIndex indexName=idx_field_parent_id, tableName=metabase_field', 'Added 0.32.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::103::camsaul
-- Added 0.32.10
ALTER TABLE metabase.metabase_database ADD auto_run_queries BOOLEAN DEFAULT TRUE NOT NULL;

COMMENT ON COLUMN metabase.metabase_database.auto_run_queries IS 'Whether to automatically run queries when doing simple filtering and summarizing in the Query Builder.';

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('103', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 96, '8:fda3670fd16a40fd9d0f89a003098d54', 'addColumn tableName=metabase_database', 'Added 0.32.10', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::106::sb
-- Added 0.34.0
ALTER TABLE metabase.metabase_field ALTER COLUMN database_type TYPE TEXT USING (database_type::TEXT);

INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('106', 'sb', 'migrations/000_migrations.yaml', NOW(), 97, '8:a3dd42bbe25c415ce21e4c180dc1c1d7', 'modifyDataType columnName=database_type, tableName=metabase_field', 'Added 0.34.0', 'EXECUTED', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::107::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('107', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 98, '8:605c2b4d212315c83727aa3d914cf57f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::108::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('108', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 99, '8:d11419da9384fd27d7b1670707ac864c', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::109::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('109', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 100, '8:a5f4ea412eb1d5c1bc824046ad11692f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::110::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('110', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 101, '8:82343097044b9652f73f3d3a2ddd04fe', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::111::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('111', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 102, '8:528de1245ba3aa106871d3e5b3eee0ba', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::112::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('112', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 103, '8:010a3931299429d1adfa91941c806ea4', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::113::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('113', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 104, '8:8f8e0836064bdea82487ecf64a129767', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::114::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('114', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 105, '8:7a0bcb25ece6d9a311d6c6be7ed89bb7', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::115::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('115', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 106, '8:55c10c2ff7e967e3ea1fdffc5aeed93a', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::116::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('116', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 107, '8:dbf7c3a1d8b1eb77b7f5888126b13c2e', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::117::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('117', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 108, '8:f2d7f9fb1b6713bc5362fe40bfe3f91f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::118::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('118', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 109, '8:17f4410e30a0c7e84a36517ebf4dab64', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::119::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('119', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 110, '8:195cf171ac1d5531e455baf44d9d6561', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::120::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('120', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 111, '8:61f53fac337020aec71868656a719bba', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::121::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('121', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 112, '8:1baa145d2ffe1e18d097a63a95476c5f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::122::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('122', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 113, '8:929b3c551a8f631cdce2511612d82d62', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::123::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('123', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 114, '8:35e5baddf78df5829fe6889d216436e5', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::124::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('124', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 115, '8:ce2322ca187dfac51be8f12f6a132818', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::125::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('125', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 116, '8:dd948ac004ceb9d0a300a8e06806945f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::126::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('126', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 117, '8:3d34c0d4e5dbb32b432b83d5322e2aa3', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::127::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('127', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 118, '8:18314b269fe11898a433ca9048400975', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::128::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('128', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 119, '8:44acbe257817286d88b7892e79363b66', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::129::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('129', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 120, '8:f890168c47cc2113a8af77ed3875c4b3', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::130::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('130', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 121, '8:ecdcf1fd66b3477e5b6882c3286b2fd8', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::131::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('131', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 122, '8:453af2935194978c65b19eae445d85c9', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::132::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('132', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 123, '8:d2c37bc80b42a15b65f148bcb1daa86e', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::133::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('133', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 124, '8:5b9b539d146fbdb762577dc98e7f3430', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::134::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('134', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 125, '8:4d0f688a168db3e357a808263b6ad355', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::135::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('135', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 126, '8:2ca54b0828c6aca615fb42064f1ec728', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::136::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('136', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 127, '8:7115eebbcf664509b9fc0c39cb6f29e9', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::137::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('137', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 128, '8:da754ac6e51313a32de6f6389b29e1ca', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::138::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('138', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 129, '8:bfb201761052189e96538f0de3ac76cf', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::139::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('139', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 130, '8:fdad4ec86aefb0cdf850b1929b618508', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::140::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('140', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 131, '8:a0cfe6468160bba8c9d602da736c41fb', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::141::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('141', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 132, '8:b6b7faa02cba069e1ed13e365f59cb6b', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::142::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('142', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 133, '8:0c291eb50cc0f1fef3d55cfe6b62bedb', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::143::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('143', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 134, '8:3d9a5cb41f77a33e834d0562fdddeab6', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::144::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('144', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 135, '8:1d5b7f79f97906105e90d330a17c4062', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::145::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('145', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 136, '8:b162dd48ef850ab4300e2d714eac504e', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::146::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('146', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 137, '8:8c0c1861582d15fe7859358f5d553c91', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::147::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('147', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 138, '8:5ccf590332ea0744414e40a990a43275', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::148::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('148', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 139, '8:12b42e87d40cd7b6399c1fb0c6704fa7', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::149::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('149', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 140, '8:dd45bfc4af5e05701a064a5f2a046d7f', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::150::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('150', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 141, '8:48beda94aeaa494f798c38a66b90fb2a', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::151::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('151', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 142, '8:bb752a7d09d437c7ac294d5ab2600079', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::152::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('152', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 143, '8:4bcbc472f2d6ae3a5e7eca425940e52b', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::153::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('153', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 144, '8:adce2cca96fe0531b00f9bed6bed8352', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::154::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('154', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 145, '8:7a1df4f7a679f47459ea1a1c0991cfba', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::155::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('155', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 146, '8:3c78b79c784e3a3ce09a77db1b1d0374', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::156::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('156', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 147, '8:51859ee6cca4aca9d141a3350eb5d6b1', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::157::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('157', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 148, '8:0197c46bf8536a75dbf7e9aee731f3b2', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::158::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('158', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 149, '8:2ebdd5a179ce2487b2e23b6be74a407c', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::159::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('159', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 150, '8:c62719dad239c51f045315273b56e2a9', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Changeset migrations/000_migrations.yaml::160::camsaul
-- Added 0.34.2
INSERT INTO metabase.databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('160', 'camsaul', 'migrations/000_migrations.yaml', NOW(), 151, '8:1441c71af662abb809cba3b3b360ce81', 'sql', 'Added 0.34.2', 'MARK_RAN', NULL, NULL, '3.6.3', '3474363696');

-- Release Database Lock
UPDATE metabase.databasechangeloglock SET LOCKED = FALSE, LOCKEDBY = NULL, LOCKGRANTED = NULL WHERE ID = 1;


