DROP TABLE IF EXISTS app.response_codes;
CREATE TABLE app.response_codes (
  code INTEGER PRIMARY KEY,
  codestring TEXT NOT NULL
);

INSERT INTO app.response_codes(code, codestring) VALUES
  (200, 'OK'),
  (404, 'NOT FOUND');
