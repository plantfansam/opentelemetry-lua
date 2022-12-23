------------------------------------------------------------------------------------------------------------------------
-- Per the spec, is used to annotate telemetry, adding context and information to metrics, traces, and logs.
--
-- @module api.baggage
------------------------------------------------------------------------------------------------------------------------

local util = require("opentelemetry.api.utils.utils")

local _M = {
}

local mt = {
    __index = _M
}


------------------------------------------------------------------------------------------------------------------------
-- Create a new @{api.baggage} instance
--
-- @param[type=table] values Table representing baggage k/v pairs. Looks something like
-- { keyname = { value = "value", metadata = "metadatastring"} }-
--
-- @return @{api.baggage}
------------------------------------------------------------------------------------------------------------------------
function _M.new(values)
    return setmetatable({ values = values or {} }, mt)
end

------------------------------------------------------------------------------------------------------------------------
-- Set a value in a baggage instance. Does _not_ inject into context
--
-- @param[type=string] name Name for which to set the value in baggage
-- @param[type=string] value Value to set
-- @param[type=string] metadata Metadata set in baggage
--
-- @return @{api.baggage}
------------------------------------------------------------------------------------------------------------------------
function _M:set_value(name, value, metadata)
    local new_values = util.shallow_copy_table(self.values)
    new_values[name] = { value = value, metadata = metadata }
    return self.new(new_values)
end

------------------------------------------------------------------------------------------------------------------------
-- Get value stored at a specific name in a baggage instance.
--
-- @param[type=string] name Name for which to set the value in baggage
--
-- @return[type=string or nil]
------------------------------------------------------------------------------------------------------------------------
function _M:get_value(name)
    if self.values[name] then
        return self.values[name].value
    else
        return nil
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Remove value stored at a specific name in a baggage instance.
--
-- @param[type=string] name Name to remove from baggage
--
-- @return @{api.baggage}
------------------------------------------------------------------------------------------------------------------------
function _M:remove_value(name)
    local new_values = util.shallow_copy_table(self.values)
    new_values[name] = nil
    return self.new(new_values)
end

------------------------------------------------------------------------------------------------------------------------
-- Get all values in a baggage instance. This is supposed to return an immutable
-- collection, but we just return a copy of the table stored at values.
--
-- @return table like { keyname = { value = "value", metadata = "metadatastring"} }
------------------------------------------------------------------------------------------------------------------------
function _M:get_all_values(self)
    return util.shallow_copy_table(self.values)
end

return _M
