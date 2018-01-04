--- requires ./types.sql

DROP TABLE IF EXISTS app.routes;

CREATE TABLE app.routes (
  priority SERIAL,
  uri_match text NULL,
  method_match app.method[] NULL,
  route_to TEXT NOT NULL
);

CREATE OR REPLACE FUNCTION app._router__run (query text, request app.request)
RETURNS app.response AS $$
  DECLARE
    result app.response;
  BEGIN
    EXECUTE query USING request INTO STRICT result;
    RETURN result;
  END
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION app.route(request app.request)
RETURNS app.response AS $$
  SELECT app._router__run('SELECT (' || route_to || ').*;', request)
    FROM app.routes
    WHERE COALESCE(request.uri ~ uri_match, true)
      AND COALESCE(ARRAY[request.method] <@ method_match, true)
    ORDER BY priority DESC
    LIMIT 1
$$ LANGUAGE SQL;

INSERT INTO app.routes(priority, method_match, uri_match, route_to) VALUES
  (1000, '{GET}', '^/users$', 'app.users__index($1)'),
  (1000, '{GET}', '^/users/\d+$', 'app.users__show($1)'),
  (1000, '{POST}', '^/users$', 'app.users__create($1)'),
  (1000, '{PUT}', '^/users/\d+$', 'app.users__update($1)'),
  (1000, '{DELETE}', '^/users/\d+$', 'app.users__destroy($1)'),
  (0, NULL, NULL, 'app.system_pages__not_found($1)');
