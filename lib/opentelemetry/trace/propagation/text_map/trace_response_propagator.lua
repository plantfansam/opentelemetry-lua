--------------------------------------------------------------------------------
-- The trace response propagator is used to extract traceresponse contents from
-- a traceresponse header and inject them. It should _not_ be used to set the
-- current context, so don't use it in a composite propagator alongside the
-- trace context propagator, unless you're being very thoughtful.
--
-- See: https://w3c.github.io/trace-context/#traceresponse-header and
-- https://w3c.github.io/trace-context/#load-balancer-deferred-sampling
--------------------------------------------------------------------------------
local span_context_new = require("opentelemetry.trace.span_context").new
local text_map_getter_new = require("opentelemetry.trace.propagation.text_map.getter").new
local text_map_setter_new = require("opentelemetry.trace.propagation.text_map.setter").new
local util = require("opentelemetry.util")
local traceresponse_header = "traceresponse"
local traceresponse_header_version = "00"

local _M = {
}

local mt = {
    __index = _M,
}

--------------------------------------------------------------------------------
-- Return a new traceresponse propagator
--
-- @return              traceresponse propagator
--------------------------------------------------------------------------------
function _M.new()
    return setmetatable({
        text_map_getter = text_map_getter_new(),
        text_map_setter = text_map_setter_new(),
    }, mt)
end

--------------------------------------------------------------------------------
-- Inject a given context into the traceresponse header on an ngx.req instance
--
-- @param context        context object
-- @param carrier        nginx request
-- @param setter         setter for interacting with ngx.req
-- @return nil
--------------------------------------------------------------------------------
function _M:inject(context, carrier, setter)
    setter = setter or self.text_map_setter
    if not context:span_context().trace_id then
        return
    end
    local header_string = table.concat({
        traceresponse_header_version,
        context:span_context().trace_id,
        context:span_context().span_id,
        context:span_context().trace_flags
    }, "-")
    setter.set(carrier, traceresponse_header, header_string)
end

--------------------------------------------------------------------------------
-- Extract a context object from a traceresponse header on an ngx.req instance.
-- You should not attach contexts returned by this propagator; it simply uses
-- OpenTelemetry's well-defined context interface for consistence and ease of
-- use.
--
-- @param context       context storage
-- @param carrier       nginx request
-- @param getter        getter for interacting with ngx.req
-- @return nil
--------------------------------------------------------------------------------
function _M:extract(context, carrier, getter)
    getter = getter or self.text_map_getter
    local traceresponse_string = getter.get(carrier, traceresponse_header)
    if not traceresponse_string then
        return context
    end

    local traceresponse = self.parse_trace_response(traceresponse_string)
    if not traceresponse.valid then
        return context
    end

    return context:with_span_context(
        span_context_new(
            traceresponse.trace_id,
            traceresponse.child_id,
            traceresponse.trace_flags,
            "",
            true)
    )
end

--------------------------------------------------------------------------------
-- Return semantically meaningful table from traceresponse string
-- We regard the traceresponse as invalid if there are not 4 parts, separated by
-- hyphens. Further validation (trace_id, parent_id, etc.) could be advisable.
--
-- @traceresponse_string   string from traceresponse header
-- @return                 semantically meaningful traceresponse table
--------------------------------------------------------------------------------
function _M.parse_trace_response(traceresponse_string)
    local traceresponse = {
        valid = false
    }
    local split_response = util.split(util.trim(traceresponse_string), "-")
    if #split_response == 4 then
        traceresponse.version = split_response[1]
        traceresponse.trace_id = split_response[2]
        traceresponse.child_id = split_response[3]
        traceresponse.trace_flags = split_response[4]
        traceresponse.valid = true
    end
    return traceresponse
end

--------------------------------------------------------------------------------
-- Return fields that this propagator operates on.
--
-- @return              table of strings representing fields that this
--                      propagator operates on.
--------------------------------------------------------------------------------
function _M:fields()
    return { traceresponse_header }
end

return _M
