------------------------------------------------------------------------------------------------------------------------
-- The tracer is responsible for creating Spans.
--
-- @module api.trace.tracer
------------------------------------------------------------------------------------------------------------------------
local context = require("lib.opentelemetry.api.context")
local span = require("lib.opentelemetry.api.trace.span")
local span_context = require("lib.opentelemetry.api.trace.span_context")

local _M = {}

local mt = { __index = _M }

------------------------------------------------------------------------------------------------------------------------
-- Create a new tracer
--
-- @param[type=@{tracer_provider}] tracer_provider The tracer provider that created this tracer
-- @string[opt=""] schema_url The schema url that should be recorded in the emitted telemetry
-- @param[type=table,opt={}] attributes Integer-keyed table of @{api.trace.attribute} instances
--
-- @return @{api.trace.tracer}
------------------------------------------------------------------------------------------------------------------------
function _M.new(tracer_provider, schema_url, attributes)
    return setmetatable({
        tracer_provider = tracer_provider,
        schema_url = schema_url or "",
        attributes = attributes or {}
    }, mt)
end

------------------------------------------------------------------------------------------------------------------------
-- Start a span
--
-- From the spec on API-only implementations: "The API MUST return a non-recording Span with the SpanContext in the
-- parent Context (whether explicitly given or implicit current). If the Span in the parent Context is already
-- non-recording, it SHOULD be returned directly without instantiating a new Span. If the parent Context contains no
-- Span, an empty non-recording Span MUST be returned instead (i.e., having a SpanContext with all-zero Span and Trace
-- IDs, empty Tracestate, and unsampled TraceFlags). This means that a SpanContext that has been provided by a
-- configured Propagator will be propagated through to any child span and ultimately also Inject, but that no new
-- SpanContexts will be created."
--
-- Users should prefer setting attributes in this method (yes, this one!), rather than calling set_attributes on a span,
-- for both performance and sampling reasons.
--
-- @string _name The name of the span
-- @param[type=@{context},opt=current span] parent_context The parent context (a full context object, not a span context).
-- @param[type=@{span_kind},opt=INTERNAL] _span_kind The kind of span to create.
-- @param[type=table,opt={}] _attributes Integer-keyed table of @{api.trace.attribute} instances
-- @param[type=table,opt={}] _links Integer-keyed table of @{api.trace.link} instances
-- @int[opt=current time] _start_timestamp_ns Start timestamp in nanoseconds since epoch.
--
-- @return @{api.trace.span}
------------------------------------------------------------------------------------------------------------------------
function _M:start_span(_name, parent_context, _span_kind, _attributes, _links, _start_timestamp_ns)
    -- If parent context is recording, create new span where it's _not_, but reuse same span context.
    local sp = context.span_from_context(parent_context or context.current())
    if sp:is_recording() then
        local psp_ctx = sp:get_span_context()

        return span.from_span_context(span_context.new(psp_ctx.trace_id, psp_ctx.span_id, psp_ctx.trace_flags,
                                                       psp_ctx.tracestate, psp_ctx.is_remote))
    else
        -- At this point, we have a nonrecording span, either from the parent context OR the default nonrecording span
        -- returned by context.span_from_context.
        return sp
    end
end

return _M
