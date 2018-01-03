# REST PSQL WEB SERVER

Just a funny stuff on holidays. No production PLZ

## Development

- clone this repo
- ensure nginx is installed with LUA support (used to forward requests)
- copy env.bash.exaple to env.bash
- run `bin/migrate` to setup database
- run `bin/server` to listen on selected port

Logs are at `log/*`. Use `tail -F log/*` to observe them during debug

## How does it works

nginx accepts request and calls lua script wich extracts request metadata
and incodes it to json. JSON is passed to `bin/query` which executes `app.MAIN`
with `psql` and gets text response wich is passed back.
Nginx config can be found at `config/ngix.conf` and processed by sed to
replace <ROOT> with repo dir

`bin/migrate` is a siple script that applies migrations and updates objects.
In sql files macro `--- requires relative_path` prepends targeted object
migration before current. All objects and migrations are guaranteed to
be executed once during migration process, migrations also are guaranteed
to be executed once during whole database history. All .sql files are executed
inside a per-file transaction (Why not all files transaction?)

`bin/server` compiles nginx config, creates required folders and starts nginx
(as described in config, it does not daemonize, so you can exit with Ctrl+C).

config in 'config/nginx.conf' is development-only and nginx would be replaced
by something simplier (like nc?) some day

there are `app` and `data` schemas, `app` for objects (stateless)
and `data` for statefull data
