--- A simple logger that uses print(). SDK loggers should adhere to the same interface.
-- @module api.utils.logger
local env_var_settings = require("opentelemetry.api.utils.env_var_settings")
local _M = {}

local mt = { __index = _M }

local log_levels = { debug = 0, info = 1, notice = 2, warn = 3, error = 4, crit = 5, alert = 6, emerg = 7 }

--- Return a new logger instance
-- @string log_level The log level to use. Defaults to 'error'.
-- @return A new logger instance
function _M.new(log_level)
    log_level = log_level or env_var_settings.log_level
    return setmetatable({ log_level = log_levels[log_level] or log_levels.error }, mt)
end

--- Write message to stdout
-- @string message The message to write.
-- @param[type=number] instance_level The log level of the logger instance.
-- @param[type=number] callsite_level The log level at which the message was logged.
-- @return nil
local function write(message, instance_level, callsite_level)
    if instance_level > callsite_level then
        return
    end
    print("OpenTelemetry: " .. message)
end

--- Write debug message
-- @string message The message to write.
-- @return nil
function _M:debug(message)
    write(message, self.log_level, log_levels.debug)
end

--- Write info message
-- @string message The message to write.
-- @return nil
function _M:info(message)
    write(message, self.log_level, log_levels.info)
end

--- Write notice message
-- @string message The message to write.
-- @return nil
function _M:notice(message)
    write(message, self.log_level, log_levels.notice)
end

--- Write warn message
-- @string message The message to write.
-- @return nil
function _M:warn(message)
    write(message, self.log_level, log_levels.warn)
end

--- Write error message
-- @string message The message to write.
-- @return nil
function _M:error(message)
    write(message, self.log_level, log_levels.error)
end

--- Write crit message
-- @string message The message to write.
-- @return nil
function _M:crit(message)
    write(message, self.log_level, log_levels.crit)
end

--- Write alert message
-- @string message The message to write.
-- @return nil
function _M:alert(message)
    write(message, self.log_level, log_levels.alert)
end

--- Write emerg message
-- @string message The message to write.
-- @return nil
function _M:emerg(message)
    write(message, self.log_level, log_levels.emerg)
end

return _M
