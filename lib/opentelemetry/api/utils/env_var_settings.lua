--- A module containing otel-related env var settings,specified here:
-- https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/sdk-environment-variables.md
-- @module api.utils.env_vars

local function getenvWithFallback(env_var, fallback)
    local value = os.getenv(env_var)
    if value == nil then
        return fallback
    end
    return value
end

local _M = {
    log_level = getenvWithFallback("OTEL_LOG_LEVEL", "error")
}
return _M
