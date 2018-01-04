json = require "json";
shell = require "shell";
root = ngx.var.ROOT

function get_request_data()
  local data = {};
  data.method = ngx.req.get_method();
  data.uri = ngx.var.uri;
  data.headers = ngx.req.get_headers();
  data.uri_args = ngx.req.get_uri_args();
  ngx.req.read_body();
  data.body = ngx.req.get_body_data();

  return data;
end

function query_request(data)
  command = shell.escape({root.."/bin/query", json.encode(data)});
  local handle = io.popen(command);
  local result = handle:read("*a");
  return json.decode(result);
end

function set_headers(headers)
  for header, value in pairs(headers) do
    ngx.header[header] = value
  end
end

log = assert(io.open(root.."/log/json_proxy.log", "a"))

local req_data = get_request_data()
log:write("SENDING "..json.encode(req_data).."\n")

local resp_data = query_request(req_data)
log:write("RECEIVED "..json.encode(resp_data).."\n")

set_headers(resp_data.headers)
ngx.status = resp_data.status
ngx.say(resp_data.body)

log:close()
