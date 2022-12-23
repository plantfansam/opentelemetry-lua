------------------------------------------------------------------------------------------------------------------------
-- trace_flags contain details about the trace. There's only one flag right now, which indicates whether or not the
-- trace was sampled
--
-- @module api.trace.trace_flags
------------------------------------------------------------------------------------------------------------------------

local _M = {}

local mt = { __index = _M }

------------------------------------------------------------------------------------------------------------------------
-- Create a new traceflags instance. The only two valid values for the byte are 00000000 (unsampled) and 00000001
-- (sampled)
--
-- @param[type=string,opt="00"] hex_byte String represting a 2-digit hexadecimal number (which is storable in one byte)
--
-- @return @{api.trace.trace_flags}
------------------------------------------------------------------------------------------------------------------------
function _M.new(hex_byte)
    return setmetatable({ hex_byte = hex_byte or "00" }, mt)
end

return _M
