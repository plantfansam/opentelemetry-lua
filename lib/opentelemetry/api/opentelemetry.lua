------------------------------------------------------------------------------------------------------------------------
-- The entrypoint for the package.
-- !!! Requiring this file sets a global of __OTEL!
-- @module opentelemetry
------------------------------------------------------------------------------------------------------------------------

__OTEL = {}
__OTEL.logger = require('lib.opentelemetry.api.utils.logger').new()
__OTEL.tracer_provider = require('lib.opentelemetry.api.trace.tracer_provider').new()
__OTEL.context_storage = {}
