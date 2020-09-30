CREATE OR REPLACE FUNCTION metabase.truncate_tables(schema_name VARCHAR, except_tables varchar[]) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE schemaname = schema_name and not (tablename = any(except_tables));
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'TRUNCATE TABLE '|| schema_name || '.' || quote_ident(stmt.tablename) || ' RESTART IDENTITY CASCADE;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION metabase.drop_tables(schema_name VARCHAR, except_tables varchar[]) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE schemaname = schema_name and not (tablename = any(except_tables));
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'DROP TABLE ' || quote_ident(stmt.tablename) || ' CASCADE;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION metabase.reset_sequences(schema_name VARCHAR, name_database VARCHAR, exclude_tables varchar[]) RETURNS void as $$
    DECLARE
        table_name_string TEXT;
    BEGIN
		FOR table_name_string IN (
            SELECT tb.table_name FROM information_schema.tables AS tb INNER JOIN information_schema.columns AS cols ON 
                tb.table_name = cols.table_name WHERE tb.table_catalog=name_database 
                AND tb.table_schema=schema_name AND cols.column_name='id' AND NOT (tb.table_name = any(exclude_tables))
            ) 
        LOOP
            EXECUTE 'SELECT setval('|| '''' || schema_name || '.' || table_name_string || '_id_seq' || '''' ||',0);';
        END LOOP;
  END;
 $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION metabase.alter_schemas(old_schema VARCHAR, new_schema VARCHAR, tables_names varchar[]) RETURNS void as $$
    DECLARE
        table_name TEXT;
    BEGIN
		FOREACH table_name IN ARRAY tables_names
        LOOP
            EXECUTE 'ALTER TABLE ' || old_schema ||'.'||   table_name || ' SET SCHEMA ' || new_schema || ';';
        END LOOP;
  END;
 $$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION metabase.disable_triggers(schema_name VARCHAR) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE schemaname = schema_name;
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'ALTER TABLE ' || quote_ident(stmt.tablename)  || ' DISABLE TRIGGER ALL;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION metabase.enable_triggers(schema_name VARCHAR) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE schemaname = schema_name;
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'ALTER TABLE ' || quote_ident(stmt.tablename)  || ' ENABLE TRIGGER ALL;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION metabase.grant_all_metabase(user_to_grant VARCHAR) RETURNS void as $$
    DECLARE
        table_name_string TEXT;
    BEGIN
		FOR table_name_string IN (
            SELECT tb.table_name FROM information_schema.tables AS tb WHERE tb.table_catalog='metabase' 
                AND tb.table_schema='metabase'
            ) 
        LOOP
            EXECUTE 'GRANT ALL ON TABLE metabase.' || table_name_string || ' TO ' || user_to_grant ||';';
        END LOOP;
  END;
 $$ LANGUAGE plpgsql;