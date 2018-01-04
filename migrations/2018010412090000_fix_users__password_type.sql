CREATE TYPE data.password AS (
  digest text,
  salt text
);

DELETE FROM data.users;

ALTER TABLE data.users
  DROP password_hash,
  ADD password data.password NOT NULL;
