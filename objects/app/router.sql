--- requires ./types.sql

DROP TABLE IF EXISTS app.routes;

CREATE TABLE app.routes (
  priority SERIAL,
  uri_match text NULL,
  method_match app.method[] NULL,
  route_to TEXT NOT NULL
);

CREATE OR REPLACE FUNCTION app.route(request app.request)
RETURNS app.response AS $$
DECLARE
  match text;
  result app.response;
BEGIN
  match := (
    SELECT route_to
    FROM app.routes
    WHERE COALESCE(request.uri LIKE uri_match, true)
      AND COALESCE(ARRAY[request.method] <@ method_match, true)
    ORDER BY priority DESC
    LIMIT 1
  );

  EXECUTE match USING request INTO STRICT result;
  return result;
END
$$ LANGUAGE PLPGSQL;

INSERT INTO app.routes(priority, uri_match, method_match, route_to) VALUES
  (0, NULL, NULL, 'SELECT app.system_pages__not_found($1) :: app.response')
