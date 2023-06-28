local tracer_provider_new = require("opentelemetry.trace.tracer_provider").new
local batch_span_processor_new = require("opentelemetry.trace.batch_span_processor").new
local console_exporter_new = require("opentelemetry.trace.exporter.console").new
local new_context = require("opentelemetry.context").new

local _M = {}

function _M.init_worker()
    -- create exporter
    local exporter = console_exporter_new()

    -- create span processor
    local bsp = batch_span_processor_new(exporter, {
        max_queue_size = ngx.worker.pid(),
        max_export_batch_size = 4,
        batch_timeout = 1,
    })

    -- create tracer provider
    local tp = tracer_provider_new(bsp)

    -- create tracer
    _M.tracer = tp:tracer("ingress_nginx.plugins.opentelemetry", {
        version = "MONITORAMA RULES",
        schema_url = "monitoringsocks.biz/not-a-real-site"
    })

    -- Log some stuff
    ngx.log(ngx.ERR,
        "worker pid: " .. ngx.worker.pid() .. " max queue size: " .. bsp.max_queue_size)
end

function _M.rewrite()
    local ctx, span = _M.tracer:start(new_context(), "demo endpoint")
    ngx.log(ngx.ERR, "worker pid: " .. ngx.worker.pid() .. " span id: " .. span.ctx.span_id .. " | ")
    ngx.ctx["opentelemetry"] = {
        span_ctx = ctx
    }
end

function _M.log()
    ngx.ctx.opentelemetry.span_ctx.sp:finish()
end

return _M
