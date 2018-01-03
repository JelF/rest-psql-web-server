CREATE TYPE data.user_role AS ENUM ('user', 'admin');

CREATE TABLE data.users (
  id SERIAL,
  email TEXT NOT NULL CONSTRAINT valid_email CHECK (email LIKE '%@%.%'),
  password_hash TEXT NOT NULL,
  role data.user_role NOT NULL DEFAULT 'user'
);
