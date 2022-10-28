local _M = {}

------------------------------------------------------------------
-- This is meant to mock out the ngx var, which responds to
-- ngx.req.get_headers()["headername"] and
-- ngx.req.set_header("headername", "value")
-- See: https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/#ngxreqset_header
------------------------------------------------------------------
function _M.new_carrier(headers_table)
    local r = {
        req = { headers = {} },
    }
    r.req.headers = headers_table
    r.req.get_headers = function() return r.req.headers end
    r.req.set_header = function(name, val) r.req.headers[name] = val end
    return r
end

------------------------------------------------------------------
-- This is meant to mock out the ngx var, which responds to
-- ngx.resp.get_headers()["headername"] and
-- ngx.headers["headername"] = "value"
-- See https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/#ngxrespget_headers
-- and https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/#ngxheaderheader
------------------------------------------------------------------
function _M.new_response_header_carrier(headers_table)
    local r = {
        header = {},
        resp = {},
    }
    r.header = headers_table
    r.resp.get_headers = function() return r.header end
    return r
end

return _M
