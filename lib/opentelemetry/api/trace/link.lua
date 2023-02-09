------------------------------------------------------------------------------------------------------------------------
-- A Span may be linked to zero or more other Spans (defined by SpanContext) that are causally related. Links can point
-- to Spans inside a single Trace or across different Traces. Links can be used to represent batched operations where a
-- Span was initiated by multiple initiating Spans, each representing a single incoming item being processed in the
-- batch.
--
-- @module api.trace.link
------------------------------------------------------------------------------------------------------------------------
local _M = {}

------------------------------------------------------------------------------------------------------------------------
-- Create a link
--
-- @param[type=@{api.trace.span_context}] span_context The span context to link to
-- @param[type=table,opt={}] attributes Table of attributes describing the link.
--
-- @return @{api.trace.link}
------------------------------------------------------------------------------------------------------------------------
function _M.new(span_context, attributes)
    return setmetatable({ span_context = span_context, attributes = attributes }, { __index = _M })
end

return _M
