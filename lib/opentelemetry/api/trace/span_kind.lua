------------------------------------------------------------------------------------------------------------------------
-- The span kind describes the relationship between the span, its parents, and its children in a Trace.
--
-- @module api.trace.span_kind
------------------------------------------------------------------------------------------------------------------------
local _M

--- Map of span kinds
-- @field UNSPECIFIED
-- @field INTERNAL Default value. Indicates that the span represents an internal operation within an application, as opposed to an operations with remote parents or children.
-- @field SERVER  Indicates that the span covers server-side handling of a synchronous RPC or other remote request.
-- @field PRODUCER Indicates that the span describes the initiators of an asynchronous request.
-- @field CLIENT Indicates that the span describes a request to some remote service.
-- @field CONSUMER Indicates that the span describes a child of an asynchronous PRODUCER request.
_M = { UNSPECIFIED = 0, INTERNAL = 1, SERVER = 2, PRODUCER = 4, CLIENT = 3, CONSUMER = 5 }

function _M:new()
    return setmetatable({}, { index = self })
end

return _M
