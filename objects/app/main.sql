--- requires ./util.sql
--- requires ./router.sql

CREATE OR REPLACE FUNCTION app.MAIN (data json)
RETURNS json AS $$
  SELECT row_to_json(
    app.route(json_populate_record(null:: app.request, data)),
    false
  );
$$ LANGUAGE SQL;
