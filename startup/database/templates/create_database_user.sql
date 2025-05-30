-- create_database_user.sql
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT FROM pg_roles WHERE rolname = '${DB_USERNAME}'
    ) THEN
      CREATE ROLE ${DB_USERNAME} WITH LOGIN PASSWORD '${DB_PASSWORD}';
    END IF;
  END
$$;

GRANT USAGE ON SCHEMA public TO ${DB_USERNAME};
GRANT CREATE ON SCHEMA public TO ${DB_USERNAME};
ALTER ROLE ${DB_USERNAME} CREATEDB;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${DB_USERNAME};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO ${DB_USERNAME};
-- ALTER USER ${DB_USERNAME} WITH SUPERUSER;
-- End of create_database_user.sql
