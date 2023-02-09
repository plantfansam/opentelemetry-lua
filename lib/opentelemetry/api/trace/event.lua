------------------------------------------------------------------------------------------------------------------------
-- An event is something that happens during a span
--
-- @module api.trace.event
------------------------------------------------------------------------------------------------------------------------
local utils = require("opentelemetry.api.utils.utils")

local _M = {}

------------------------------------------------------------------------------------------------------------------------
-- Create an event
--
-- @param[type=string] name The name of the event
-- @param[type=table,opt={}] attributes Table of attributes for the event
-- @param[type=number,opt=now] timestamp Timestamp of the event in nanoseconds since epoch.
--
-- @return @{api.trace.event}
------------------------------------------------------------------------------------------------------------------------
function _M.new(name, attributes, timestamp)
    return setmetatable({ name = name, attributes = attributes, timestamp = timestamp or utils.time_nano() },
                        { __index = _M })
end

return _M
