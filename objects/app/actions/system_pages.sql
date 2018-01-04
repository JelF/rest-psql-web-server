--- requires ./utils.sql

CREATE OR REPLACE FUNCTION app.system_pages__not_found(request app.request)
RETURNS app.response AS $$
  SELECT app.render_json(404, '{"result": "not_found"}')
$$ LANGUAGE SQL;
