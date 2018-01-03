--- requires ./response_codes.sql
--- requires ./types.sql

CREATE OR REPLACE FUNCTION app.write_response (response app.response)
RETURNS text AS $$
  SELECT string_agg(line, '\n')
  FROM (
    (
      SELECT 'HTTP/1.1 ' ||
             response.code ||
             (SELECT codestring FROM app.response_codes
               WHERE code = response.code LIMIT 1)
    ) UNION ALL (
      SELECT name || ': ' || value
      FROM json_each_text(response.headers) headers(name, value)
    ) UNION ALL (
      SELECT ''
    ) UNION ALL (
      SELECT response.body
    )
  ) lines(line)
$$ LANGUAGE SQL;
