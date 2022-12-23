------------------------------------------------------------------------------------------------------------------------
-- Grab bag of utils. We try to localize most LuaJIT-specific stuff here.
--
-- @module api.utils.utils
------------------------------------------------------------------------------------------------------------------------
local _M = {}

local function shallow_copy_table(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

------------------------------------------------------------------------------------------------------------------------
-- Convert a hex string to a binary string
--
-- There are likely other, better ways to do this, but we don't want to pull in a dependency, and we also want to
-- maintain compatibility with Lua 5.1, which is LuaJIT's latest supported release. If you know a better, faster way to
-- do this, please make a PR! The premise is that we match an input string on 2 hexadecimal characters (%x%x) - each hex
-- character is 4 bits, or half a byte -- and then turn the two characters — interpreted together — as a decimal number
-- (tonumber takes an arg which specifies the base to use in conversion). Once we have a decimap, we call string.char on
-- that, which returns a "character [that] has the internal numerical code equal to its corresponding argument." We do
-- this for each hexadecimal byte and stitch it all together. This means we're basically creating a string of bytes that
-- correspond to non-alphanumeric ASCII codes (BEL, ACK, etc.) that have the binary encoding we want. This ultimately
-- plays nicely with our protobuf library, so there you go.
--
-- @string hex A string of hex digits
--
-- @return A binary string representing the number encoded in the hex digits
------------------------------------------------------------------------------------------------------------------------
local function hex_to_binary(hex)
    return (hex:gsub('%x%x', function(cc)
        local n = tonumber(cc, 16)
        if n then
            return string.char(n)
        end
    end))
end

------------------------------------------------------------------------------------------------------------------------
-- @param[type=integer] i A number between 0 and 255
--
-- @return[type=string] A zero-padded hexadecimal representation of the number
------------------------------------------------------------------------------------------------------------------------
local function int_to_hex(i)
    return string.format("%02x", i)
end

local function hex_to_char(hex)
    return string.char(tonumber(hex, 16))
end

local function char_to_hex(c)
    return string.format("%%%02X", string.byte(c))
end

-- Baggage headers values can be percent encoded. We need to unescape them. The
-- regex is a bit weird-looking, so here's the relevant section on patterns in
-- the Lua manual (https://www.lua.org/manual/5.2/manual.html#6.4.1)
local function decode_percent_encoded_string(str)
    return str:gsub("%%(%x%x)", hex_to_char)
end

------------------------------------------------------------------------------------------------------------------------
-- Percent encode a baggage string. It's not generic for all percent encoding,
-- since we don't want to percent-encode equals signs, semicolons, or commas in
-- baggage strings.
--
-- @param[type=string] string String to be sent as baggage list item
-- @return              new context with baggage associated
------------------------------------------------------------------------------------------------------------------------
-- adapted from https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
local function percent_encode_baggage_string(string)
    if str == nil then
        return
    end
    str = str:gsub("\n", "\r\n")
    str = str:gsub("([^%w ,;=_%%%-%.~])", char_to_hex)
    str = str:gsub(" ", "+")
    return str
end

------------------------------------------------------------------------------------------------------------------------
-- Recursively render a table as a string
-- Code from http://lua-users.org/wiki/TableSerialization
------------------------------------------------------------------------------------------------------------------------
local function table_as_string(tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs(tt) do
            table.insert(sb, string.rep(" ", indent)) -- indent it
            if type(value) == "table" and not done[value] then
                done[value] = true
                table.insert(sb, key .. " = {\n");
                table.insert(sb, table_as_string(value, indent + 2, done))
                table.insert(sb, string.rep(" ", indent)) -- indent it
                table.insert(sb, "}\n");
            elseif "number" == type(key) then
                table.insert(sb, string.format("\"%s\"\n", tostring(value)))
            else
                table.insert(sb, string.format("%s = \"%s\"\n", tostring(key), tostring(value)))
            end
        end
        return table.concat(sb)
    else
        return tt .. "\n"
    end
end

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function trim(s)
    return s:match '^%s*(.*%S)' or ''
end

_M.shallow_copy_table = shallow_copy_table
_M.decode_percent_encoded_string = decode_percent_encoded_string
_M.percent_encode_baggage_string = percent_encode_baggage_string
_M.split = split
_M.table_as_string = table_as_string
_M.trim = trim
_M.hex_to_binary = hex_to_binary
_M.int_to_hex = int_to_hex
_M.random = math.random

-- default time function, will be used in this SDK
-- change it if needed
_M.time_nano = function()
end

return _M
