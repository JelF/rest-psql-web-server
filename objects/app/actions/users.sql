--- requires ./utils.sql
--- requires ../forms/user_form.sql

DROP VIEW IF EXISTS app.users__view;
CREATE VIEW app.users__view AS
  SELECT id, email, role FROM data.users;

CREATE OR REPLACE FUNCTION app._users__extract_id (request app.request)
RETURNS integer AS $$
  SELECT (SELECT REGEXP_MATCHES(request.uri, '/users/(\d+)'))[1] :: integer
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION app.users__index (app.request)
RETURNS app.response AS $$
  SELECT app.render_json(
    json_build_object('users', COALESCE(JSON_AGG(app.users__view.*), '[]'))
  ) FROM app.users__view;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION app.users__show (request app.request)
RETURNS app.response AS $$
  WITH user_view AS (
    SELECT ROW_TO_JSON(app.users__view.*)
    FROM app.users__view
    WHERE id = app._users__extract_id(request)
    LIMIT 1
  ) SELECT (
      CASE
      WHEN EXISTS (SELECT * FROM user_view) THEN
        (SELECT app.render_json(json_build_object('user', user_view.*))
           FROM user_view)
      ELSE
        app.system_pages__not_found(request)
      END
    );
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION app.users__create (request app.request)
RETURNS app.response AS $$
DECLARE
  form app.user_form;
  errors app.forms__error[];
  data app.user_form__data;
  user_id integer;
  response app.response;
BEGIN
  form := json_populate_record(
    null::app.user_form,
    CAST(request.body AS json) -> 'user'
  );

  errors := app.user_form__validate(form);

  IF ARRAY_LENGTH(errors, 1) > 0 THEN
    response := app.render_json(422, json_build_object('errors', errors));
  ELSE
    data = app.user_form__submit(form);
    INSERT INTO data.users(email, password) SELECT data.* RETURNING id INTO STRICT user_id;

    response:= (SELECT app.render_json(json_build_object('user', ROW_TO_JSON(app.users__view.*)))
      FROM app.users__view
      WHERE id = user_id);
  END IF;

  RETURN response;
END
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION app.users__update (request app.request)
RETURNS app.response AS $$
DECLARE
  user_id integer;
  form app.user_form;
  errors app.forms__error[];
  data app.user_form__data;
  response app.response;
BEGIN
  user_id := app._users__extract_id(request);

  form := json_populate_record(
    null::app.user_form,
    CAST(request.body AS json) -> 'user'
  );

  errors := app.user_form__validate(form);

  IF NOT EXISTS (SELECT 1 FROM data.users WHERE id = user_id) THEN
    response := app.system_pages__not_found(response);
  ELSIF ARRAY_LENGTH(errors, 1) > 0 THEN
    response := app.render_json(422, json_build_object('errors', errors));
  ELSE
    data = app.user_form__submit(form);
    UPDATE data.users
      SET email = data.email,
          password = data.password
      WHERE id = user_id;

    response:= (SELECT app.render_json(json_build_object('user', ROW_TO_JSON(app.users__view.*)))
      FROM app.users__view
      WHERE id = user_id);
  END IF;

  RETURN response;
END
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION app.users__destroy (request app.request)
RETURNS app.response AS $$
DECLARE
  user_id integer;
  response app.response;
BEGIN
  user_id := app._users__extract_id(request);
  IF NOT EXISTS (SELECT 1 FROM data.users WHERE id = user_id) THEN
    response := app.system_pages__not_found(request);
  ELSE
    DELETE FROM data.users WHERE id = user_id;
    response := app.render_json(json_build_object('status', 'success'));
  END IF;
  RETURN response;
END
$$ LANGUAGE PLPGSQL;
