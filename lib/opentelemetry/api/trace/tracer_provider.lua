--- The tracer_provider provides access to @{api.trace.tracer}(s).
-- @module api.trace.tracer_provider
local tracer = require("opentelemetry.api.trace.tracer")

local _M = {}

local mt = { __index = _M }

------------------------------------------------------------------------------------------------------------------------
-- Create a new tracer provider
--
-- @return @{api.trace.tracer_provider}
function _M.new()
    return setmetatable({ tracers = {} }, mt)
end
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Get a @{api.trace.tracer}
--
-- @string name The name of the @{api.trace.tracer_provider}. Should uniquely identify the instrumentation scope.
-- @string[opt] version The version of the instrumentation scope
-- @string[opt] schema_url The schema URL that should be recorded in the emitted telemetry
-- @param[type=table,opt] attributes Integer-keyed table of @{api.trace.attribute} instances
------------------------------------------------------------------------------------------------------------------------
function _M:get(name, version, schema_url, attributes)
    if not name then
        __OTEL.logger:info("Tried to get tracer without including name. Using 'default'")
    end

    local version = version or "unknown"
    local schema_url = schema_url or "unknown"
    local key = name .. "-" .. version .. "-" .. schema_url
    local attributes = attributes or {}

    if self.tracers[key] then
        return self.tracers[key]
    else
        self.tracers[key] = tracer.new(self, schema_url, attributes)
        return self.tracers[key]
    end
end

return _M
