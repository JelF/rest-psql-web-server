CREATE SCHEMA IF NOT EXISTS app;

CREATE TABLE IF NOT EXISTS app.migrations (
  version TEXT PRIMARY KEY
);

CREATE OR REPLACE FUNCTION app.CHECK_MIGRATION(versionID text)
RETURNS INTEGER AS $$
  SELECT 1 FROM app.migrations WHERE version = versionID LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION app.REGISTER_MIGRATION(versionID text)
RETURNS VOID AS $$
  INSERT INTO app.migrations VALUES (versionID) ON CONFLICT DO NOTHING;
$$ LANGUAGE SQL;
