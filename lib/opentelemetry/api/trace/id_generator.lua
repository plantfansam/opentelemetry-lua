------------------------------------------------------------------------------------------------------------------------
-- This API-only ID generator doesn't use any LuaJIT methods/packages.
--
-- @module api.trace.id_generator
------------------------------------------------------------------------------------------------------------------------
local utils = require "opentelemetry.api.utils.utils"

local int_to_hex = utils.int_to_hex
local fmt = string.format
local random = utils.random

local _M = {}

------------------------------------------------------------------------------------------------------------------------
-- Create a new span id. There is likely a more performant way to do this - PRs welcome!
-- TODO: investiage possibility of calling random less against larger integers.
--
-- @return[type=string] 16-character hexadecimal span id
------------------------------------------------------------------------------------------------------------------------
function _M.generate_span_id()
    return fmt("%s%s%s%s%s%s%s%s", int_to_hex(random(0, 255)), int_to_hex(random(0, 255)), int_to_hex(random(0, 255)),
               int_to_hex(random(0, 255)), int_to_hex(random(0, 255)), int_to_hex(random(0, 255)),
               int_to_hex(random(0, 255)), int_to_hex(random(0, 255)))
end

------------------------------------------------------------------------------------------------------------------------
-- Create a new trace id. There is likely a more performant way to do this - PRs welcome!
--
-- @return[type=string] 32-character hexadecimal trace id
------------------------------------------------------------------------------------------------------------------------
function _M.generate_trace_id()
    return fmt("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s", int_to_hex(random(0, 255)), int_to_hex(random(0, 255)),
               int_to_hex(random(0, 255)), int_to_hex(random(0, 255)), int_to_hex(random(0, 255)),
               int_to_hex(random(0, 255)), int_to_hex(random(0, 255)), int_to_hex(random(0, 255)),
               int_to_hex(random(0, 255)), int_to_hex(random(0, 255)), int_to_hex(random(0, 255)),
               int_to_hex(random(0, 255)), int_to_hex(random(0, 255)), int_to_hex(random(0, 255)),
               int_to_hex(random(0, 255)), int_to_hex(random(0, 255)))
end

return _M
