DROP TYPE IF EXISTS app.forms__error CASCADE;
CREATE TYPE app.forms__error AS (
  field text,
  error text
);

CREATE OR REPLACE FUNCTION app.forms__error(field text, error text)
RETURNS app.forms__error AS 'SELECT field, error;' LANGUAGE SQL
