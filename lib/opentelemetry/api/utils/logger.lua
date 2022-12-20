local _M = {}

local mt = { __index = _M }

local log_levels = { debug = 0, info = 1, notice = 2, warn = 3, error = 4, crit = 5, alert = 6, emerg = 7 }

function _M.new(log_level)
    return setmetatable({ log_level = log_levels[log_level] or log_levels.error }, mt)
end

function _M.write(self, message, callsite_level)
    if self.log_level > callsite_level then
        return
    end
    print(message)
end

function _M.debug(self, message)
    self:write(message, log_levels.debug)
end

function _M.info(self, message)
    self:write(message, log_levels.info)
end

function _M.notice(self, message)
    self:write(message, log_levels.notice)
end

function _M.warn(self, message)
    self:write(message, log_levels.warn)
end

function _M.error(self, message)
    self:write(message, log_levels.error)
end

function _M.crit(self, message)
    self:write(message, log_levels.crit)
end

function _M.alert(self, message)
    self:write(message, log_levels.alert)
end

function _M.emerg(self, message)
    self:write(message, log_levels.emerg)
end

return _M
