--- requires ../types.sql

CREATE OR REPLACE FUNCTION app.system_pages__not_found(request app.request)
RETURNS app.response AS $$
  SELECT 404 AS code,
         '{"result": "not_found"}' :: text AS body,
         '{}' :: json AS headers
$$ LANGUAGE SQL;
