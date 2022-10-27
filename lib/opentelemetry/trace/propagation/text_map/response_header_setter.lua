local _M = {
}

local mt = {
    __index = _M
}

function _M.new()
    return setmetatable({}, mt)
end

------------------------------------------------------------------
-- Add tracing information to nginx response as headers.
-- ngx.header.HEADER is used for setting response headers
-- https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/?area=default#ngxheaderheader
--
-- @param carrier (should be ngx)
-- @param key HTTP header to set
-- @param val value of HTTP header
-- @return nil
------------------------------------------------------------------
function _M.set(carrier, name, val)
    carrier.header[name] = val
end

return _M
