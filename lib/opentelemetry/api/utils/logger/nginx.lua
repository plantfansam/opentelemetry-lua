local logger = require("opentelemetry.api.utils.logger.base")
local _M = logger:new()

function _M.class_name()
    return "api.utils.logger.nginx"
end

function _M:log_levels()
    return { debug = ngx.DEBUG, info = ngx.INFO, notice = ngx.NOTICE, warn = ngx.WARN, error = ngx.ERR, crit = ngx.CRIT, alert = ngx.ALERT, emerg = ngx.EMERG }
end

function _M:write(message, configured_level, callsite_level)
    if configured_level >= self:log_levels()[callsite_level] then
        ngx.log(self:log_levels()[callsite_level], "OpenTelemetry: " .. message)
    end
end

return _M
