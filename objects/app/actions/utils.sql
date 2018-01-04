--- requires ../types.sql

CREATE OR REPLACE FUNCTION app.render_json(status integer, data json, headers jsonb)
RETURNS app.response AS $$
  SELECT status,
         CAST(data AS text) AS body,
         headers || jsonb_object('{Content-Type, application/json; charset=utf-8}')
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION app.render_json(status integer, data json)
RETURNS app.response AS $$
  SELECT app.render_json(status, data, '{}')
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION app.render_json(data json)
RETURNS app.response AS $$
  SELECT app.render_json(200, data, '{}')
$$ LANGUAGE SQL;
