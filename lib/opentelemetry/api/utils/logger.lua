local _M = {}

local mt = { __index = _M }

local log_levels = { debug = 0, info = 1, notice = 2, warn = 3, error = 4, crit = 5, alert = 6, emerg = 7 }

function _M.new(log_level)
    return setmetatable({ log_level = log_levels[log_level] or log_levels.error }, mt)
end

local function write(message, instance_level, callsite_level)
    if instance_level > callsite_level then
        return
    end
    print("OpenTelemetry: " .. message)
end

function _M:debug(message)
    write(message, self.log_level, log_levels.debug)
end

function _M:info(message)
    write(message, self.log_level, log_levels.info)
end

function _M:notice(message)
    write(message, self.log_level, log_levels.notice)
end

function _M:warn(message)
    write(message, self.log_level, log_levels.warn)
end

function _M:error(message)
    write(message, self.log_level, log_levels.error)
end

function _M:crit(message)
    write(message, self.log_level, log_levels.crit)
end

function _M:alert(message)
    write(message, self.log_level, log_levels.alert)
end

function _M:emerg(message)
    write(message, self.log_level, log_levels.emerg)
end

return _M
