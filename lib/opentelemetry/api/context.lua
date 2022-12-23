------------------------------------------------------------------------------------------------------------------------
-- The context module represents OpenTelemetry context. Beware - this is different than SpanContext!
-- @module api.context
------------------------------------------------------------------------------------------------------------------------

local _M = {
}

local span = require("lib.opentelemetry.api.trace.span")
local util = require("opentelemetry.api.utils.utils")

local mt = {
    __index = _M
}

local context_key = "__opentelemetry_context__"
local baggage_context_key = "__opentelemetry_baggage__"
local span_key = "current_span"

------------------------------------------------------------------------------------------------------------------------
-- Create new context with set of entries
--
-- @param[type=table,opt={}] entries Table of entries to set in context
--
-- @return              context
------------------------------------------------------------------------------------------------------------------------
function _M.new(entries)
    return setmetatable({ entries = entries or {} }, mt)
end

------------------------------------------------------------------------------------------------------------------------
-- Set this context object as current by pushing it on stack stored at context_key in __OTEL.context_storage.
--
-- @return Integer Token to be used for detaching
------------------------------------------------------------------------------------------------------------------------
function _M:attach()
    if __OTEL.context_storage[context_key] then
        table.insert(__OTEL.context_storage[context_key], self)
    else
        __OTEL.context_storage[context_key] = { self }
    end

    -- the length of the stack is token used to detach context
    return #__OTEL.context_storage[context_key]
end

------------------------------------------------------------------------------------------------------------------------
-- Detach current context, setting current context to previous element in stack If token does not match length of
-- elements in stack, returns false and error string.
--
-- @int token Token by the attach call, which should match the length of the stack
-- @return boolean Whether or not detach was successful
------------------------------------------------------------------------------------------------------------------------
function _M:detach(token)
    if #__OTEL.context_storage[context_key] == token then
        table.remove(__OTEL.context_storage[context_key])
        return true
    else
        local error_message = "Token does not match (" ..
            #__OTEL.context_storage[context_key] ..
            " context entries in stack, token provided was " .. token .. ")."
        __OTEL.logger:warn(error_message)
        return false
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Get current context, which is the final element in stack stored at context_key.
--
-- @return @{api.context} Current context
------------------------------------------------------------------------------------------------------------------------
function _M.current()
    if __OTEL.context_storage[context_key] then
        return __OTEL.context_storage[context_key][#__OTEL.context_storage[context_key]]
    else
        return _M.new()
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Retrieve value for key in context.
--
-- @string key Key for which to set the value in context
--
-- @return value stored at key
------------------------------------------------------------------------------------------------------------------------
function _M:get(key)
    return self.entries[key]
end

------------------------------------------------------------------------------------------------------------------------
-- Set value for key in context.
--
-- @string key Key for which to set the value in context
-- @param value Value to set to set in context
--
-- @return @{api.context} New context with value set
------------------------------------------------------------------------------------------------------------------------
function _M:set(key, value)
    local vals = util.shallow_copy_table(self.entries)
    vals[key] = value
    return self.new(vals)
end

------------------------------------------------------------------------------------------------------------------------
-- Create a new context instance with supplied span set as current.
--
-- @return @{api.context}
------------------------------------------------------------------------------------------------------------------------
function _M.with_span(span)
    return _M.new({ [span_key] = span})
end

------------------------------------------------------------------------------------------------------------------------
-- Returns span associated with this context.
--
-- @return @{api.context}
------------------------------------------------------------------------------------------------------------------------
function _M:span()
    return self.entries[span_key]
end

------------------------------------------------------------------------------------------------------------------------
-- Inject baggage into current context
--
-- @param[type=@{api.baggage}] baggage Baggage instance to inject
--
-- @return @{api.context}
------------------------------------------------------------------------------------------------------------------------
function _M:inject_baggage(baggage)
    return self:set(baggage_context_key, baggage)
end

------------------------------------------------------------------------------------------------------------------------
-- Extract baggage from context.
--
-- @return @{api.baggage}
------------------------------------------------------------------------------------------------------------------------
function _M:extract_baggage()
    return self:get(baggage_context_key)
end

------------------------------------------------------------------------------------------------------------------------
-- Returns the span from the supplied context. It defaults to the current context. If no span is present on context, it
-- returns a nonrecording span.
--
-- TODO: consider relocating this elsewhere.
-- @param[ctx=api.context] ctx Context from which to retrieve span
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M.span_from_context(ctx)
    ctx = ctx or _M.current()
    return ctx.entries[span_key] or span.non_recording_span()
end

return _M
