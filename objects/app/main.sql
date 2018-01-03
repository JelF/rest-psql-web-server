--- requires ./util.sql
--- requires ./router.sql

CREATE OR REPLACE FUNCTION app.MAIN (data json)
RETURNS text AS $$
  SELECT app.write_response(
    app.route(
      json_populate_record(null:: app.request, data)
    )
  )
$$ LANGUAGE SQL;
