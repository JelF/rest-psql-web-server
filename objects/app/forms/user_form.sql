--- requires ./utils.sql

DROP TYPE IF EXISTS app.user_form CASCADE;
CREATE TYPE app.user_form AS (
  email text,
  password text,
  password_confirmation text
);

DROP TYPE IF EXISTS app.user_form__data CASCADE;
CREATE TYPE app.user_form__data AS (
  email text,
  password data.password
);

CREATE OR REPLACE FUNCTION app.user_form__validate (form app.user_form)
RETURNS app.forms__error[] AS $$
  SELECT ARRAY_AGG(error) FROM (
    VALUES
      (app.forms__error('email', 'must be present'), form.email IS NOT NULL),
      (app.forms__error('email', 'invalid'), form.email LIKE '%@%.%'),
      (app.forms__error('password', 'must be present'), form.password IS NOT NULL),
      (app.forms__error('password', 'must be at least 5 symbols'), char_length(form.password) >= 5),
      (app.forms__error('password_confirmation', 'must be present'), form.password_confirmation IS NOT NULL),
      (app.forms__error('password_confirmation', 'must match password'), form.password_confirmation = form.password)
  ) t(error, condition)
  WHERE condition = false;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION app.user_form__submit (form app.user_form)
RETURNS app.user_form__data AS $$
DECLARE
  salt text;
  password data.password;
BEGIN
  salt := gen_salt('des');
  password := ROW(crypt(form.password, salt), salt);
  return CAST(ROW(form.email, password) AS app.user_form__data);
END
$$ LANGUAGE PLPGSQL;
