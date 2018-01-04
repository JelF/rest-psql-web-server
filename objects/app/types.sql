DROP TYPE IF EXISTS app.method CASCADE;
CREATE TYPE app.method
  AS ENUM ('GET', 'POST', 'PUT', 'PATCH', 'DELETE');

DROP TYPE IF EXISTS app.request CASCADE;
CREATE TYPE app.request AS (
  method app.method,
  headers json,
  uri_args json,
  body text,
  uri text
);

DROP TYPE IF EXISTS app.response CASCADE;
CREATE TYPE app.response AS (
  status integer,
  body text,
  headers jsonb
);
