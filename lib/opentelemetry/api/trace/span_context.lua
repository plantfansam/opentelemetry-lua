------------------------------------------------------------------------------------------------------------------------
-- From the spec, "a SpanContext represents the portion of a Span which must be serialized and propagated along side of a
-- distributed context."
--
-- @module api.trace.span_context
------------------------------------------------------------------------------------------------------------------------
local id_generator = require("opentelemetry.api.trace.id_generator")
local tracestate = require("opentelemetry.api.trace.tracestate")
local traceflags = require("opentelemetry.api.trace.traceflags")
local utils = require("opentelemetry.api.utils.utils")

local _M = { non_recording_span_ID = "0000000000000000", INVALID_TRACE_ID = "00000000000000000000000000000000" }

local mt = { __index = _M }

------------------------------------------------------------------------------------------------------------------------
-- Create a new SpanContext
--
-- @string trace_id Trace id, hexadecimal
-- @string span_id Span id, hexadecimal
-- @param[type=@{api.trace.trace_flags},opt=unsampled] trace_flags Trace flags instance
-- @param[type=@{api.trace.trace_state},opt={}] trace_state Trace state instance
-- @param[type=boolean,opt=false] remote Whether or not the span context was propagated from remote parent
--
-- @return @{api.trace.span_context}
------------------------------------------------------------------------------------------------------------------------
function _M.new(trace_id, span_id, trace_flags, trace_state, remote)
    local self = {
        trace_id = trace_id or id_generator.generate_trace_id(),
        span_id = span_id or id_generator.generate_span_id(),
        traceflags = trace_flags or traceflags.new(),
        trace_state = trace_state or tracestate.new({}),
        remote = remote or false
    }
    return setmetatable(self, mt)
end

------------------------------------------------------------------------------------------------------------------------
-- Whether or not the span is sampled.
-- We use a simple string comparison, here, because the only valid values for traceflags are "00" and "01".
--
-- @return boolean
------------------------------------------------------------------------------------------------------------------------
function _M:is_sampled()
    return self.traceflags.hex_byte == "01"
end

------------------------------------------------------------------------------------------------------------------------
-- Hexadecimal representation of the trace_id
--
-- @return[type=string] string
------------------------------------------------------------------------------------------------------------------------
function _M:hex_trace_id()
    return self.trace_id
end

------------------------------------------------------------------------------------------------------------------------
-- Binary representation of the trace_id
--
-- @return[type=string] string
------------------------------------------------------------------------------------------------------------------------
function _M:binary_trace_id()
    utils.hex_to_binary(self.trace_id)
end

------------------------------------------------------------------------------------------------------------------------
-- Hexadecimal representation of the span_id
--
-- @return[type=string] string
------------------------------------------------------------------------------------------------------------------------
function _M:hex_span_id()
    return self.trace_id
end

------------------------------------------------------------------------------------------------------------------------
-- Binary representation of the span_id
--
-- @return[type=string] string
------------------------------------------------------------------------------------------------------------------------
function _M:binary_span_id()
    utils.hex_to_binary(self.span_id)
end

------------------------------------------------------------------------------------------------------------------------
-- Returns true if trace id and span id are nonzero
--
-- @return[type=boolean]
------------------------------------------------------------------------------------------------------------------------
function _M:is_valid()
    return self.trace_id ~= self.INVALID_TRACE_ID and self.span_id ~= self.non_recording_span_ID
end

------------------------------------------------------------------------------------------------------------------------
-- Returns true if span context was propagated from remote parent
--
-- @return[type=boolean]
------------------------------------------------------------------------------------------------------------------------
function _M:is_remote()
    return self.remote
end

return _M
