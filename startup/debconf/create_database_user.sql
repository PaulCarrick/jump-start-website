DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT FROM pg_roles WHERE rolname = '{db_username}'
    ) THEN
      CREATE ROLE {db_username} WITH LOGIN PASSWORD '{db_password}';
    END IF;
  END
$$;

GRANT USAGE ON SCHEMA public TO {db_username};
GRANT CREATE ON SCHEMA public TO {db_username};
ALTER ROLE {db_username} CREATEDB;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO {db_username};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO {db_username};
