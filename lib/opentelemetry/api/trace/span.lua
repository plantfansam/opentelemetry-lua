------------------------------------------------------------------------------------------------------------------------
-- Span represents a single operation in a trace. API spans are mostly no-ops.
--
-- @module api.trace.span
------------------------------------------------------------------------------------------------------------------------
local span_context = require('opentelemetry.api.trace.span_context')

local _M = {}

------------------------------------------------------------------------------------------------------------------------
-- Creates a new span. Should not be called directly by users — always create spans through a tracer.
--
-- @tparam[opt] @{api.trace.span_context} span_ctx The span context to use for the new span
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:new(span_ctx)
    return setmetatable({ span_context = span_ctx or span_context.new() }, { __index = self })
end

------------------------------------------------------------------------------------------------------------------------
-- Returns span context associated with span
--
-- @return @{api.trace.span_context}
------------------------------------------------------------------------------------------------------------------------
function _M:get_span_context()
    return self.span_context
end

------------------------------------------------------------------------------------------------------------------------
-- Returns whether or not the span is recording. Always false for API spans.
--
-- @return boolean
------------------------------------------------------------------------------------------------------------------------
function _M:is_recording()
    return false
end

------------------------------------------------------------------------------------------------------------------------
-- Sets single attribute on the span. This is a noop for API spans.
--
-- @param[type=string] _k Attribute key
-- @param[type={string|number|bool|table}] _v Attribute value
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:set_attribute(_k, _v)
    return self
end

------------------------------------------------------------------------------------------------------------------------
-- Sets multiple attributes on the span. This is a noop for API spans.
--
-- @param[type=table] _attributes Table of attributes to set on the span.
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:set_attributes(_attributes)
    return self
end

------------------------------------------------------------------------------------------------------------------------
-- Add an event to the span. This is a noop for API spans.
--
-- @param[type=string] _name Name of the event
-- @param[type=table] _attributes Table of attributes to set on the span.
-- @param[type=number,opt=now] _timestamp Timestamp of the event in nanoseconds since epoch.
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:add_event(_name, _attributes, _timestamp)
    return self
end

------------------------------------------------------------------------------------------------------------------------
-- Sets status on span. This is a noop for API spans.
--
-- @param[type=int] _status Span status code to set on span (@see @{api.trace.span_status} for constants)
-- @param[type=string] _description Description of the status, only to be used when status is errored
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:set_status(_status, _description)
    return self
end

------------------------------------------------------------------------------------------------------------------------
-- Updates the span name. This is a noop for API spans.
--
-- @param[type=string] _name New name for span
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:update_name(_name)
    return self
end

------------------------------------------------------------------------------------------------------------------------
-- Signals that operation described by this span has ended. Noops in API spans. We use finish because end is a reserved
-- word.
--
-- @param[type=int,opt=now] _timestamp Timestamp to mark as span end time (defaults to now)
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:finish(_timestamp)
    return self
end

------------------------------------------------------------------------------------------------------------------------
-- Records an exception as an event on the span. Noops in API spans.
--
-- @param[type=int,opt=now] _exception_string String description of the exception (e.g. "COULD NOT CONNECT TO UPSTREAM")
-- @param[type=table,opt={}] _attributes Optional table of attributes to set on the event.
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:record_exception(_exception_string, _attributes)
    return self
end

------------------------------------------------------------------------------------------------------------------------
-- Instantiates a new non-recording span.
--
-- @param[type=@{api.trace.span_context},opt[invalid span]] span_ctx Span context to use
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M.non_recording_span(span_ctx)
    span_ctx = span_ctx or span_context.new(span_context.INVALID_TRACE_ID, span_context.non_recording_span_ID)
    return _M.new(_M, span_ctx)
end

------------------------------------------------------------------------------------------------------------------------
-- Creates a new span from a span context object.
--
-- @param[type=@{api.trace.span_context}] span_context Span context to use
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M.from_span_context(span_context)
    return _M.new(_M, span_context)
end

return _M
