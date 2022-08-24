local metrics_reporter = require("opentelemetry.metrics_reporter")

local _M = { context_storage = ngx.ctx, metrics_reporter = metrics_reporter }

function _M.set_tracer_provider(tp)
    _M.tracer_provider = tp
end

function _M.get_tracer_provider()
    return _M.tracer_provider
end

function _M.set_metrics_reporter(metrics_reporter)
    _M.metrics_reporter = metrics_reporter
end

function _M.tracer(name, opts)
    return _M.tracer_provider:tracer(name, opts)
end

function _M.set_context_storage(context_storage)
    _M.context_storage = context_storage
end

return _M
