--- requires ../types.sql

CREATE OR REPLACE FUNCTION app.system_pages__not_found(request app.request)
RETURNS app.response AS $$
  SELECT 404 AS status,
         '{"result": "not_found"}' :: text AS body,
         '{"content-type": "application/json"}' :: json AS headers
$$ LANGUAGE SQL;
