local otel_global = require("opentelemetry.global")
local timer_at = ngx.timer.at
local now = ngx.now
local batch_size_metric = "otel.bsp.batch_size"
local buffer_utilization_metric = "otel.bsp.buffer_utilization"
local dropped_spans_metric = "otel.bsp.dropped_spans"
local export_success_metric = "otel.bsp.export.success"
local exported_spans_metric = "otel.bsp.exported_spans"
local exporter_failure_metric = "otel.otlp_exporter.failure"

local _M = {
}

local mt = {
    __index = _M
}

local function report_dropped_spans(count, reason)
    otel_global.metrics_reporter:add_to_counter(
        dropped_spans_metric, count, { reason = reason })
end

local function report_result(success, err, batch_size)
    if success then
        otel_global.metrics_reporter:add_to_counter(
            export_success_metric, 1)
        otel_global.metrics_reporter:add_to_counter(
            exported_spans_metric, batch_size)
    else
        err = err or "unknown"
        otel_global.metrics_reporter:add_to_counter(
            exporter_failure_metric, 1, { reason = err })
        report_dropped_spans(batch_size, err)
    end
end

local function process_batches(premature, self, batches)
    if premature then
        return
    end
    otel_global.metrics_reporter:observe_value(buffer_utilization_metric, #self.queue / self.max_queue_size)

    for _, batch in ipairs(batches) do
        otel_global.metrics_reporter:record_value(batch_size_metric, #batch)
        local success, err = self.exporter:export_spans(batch)
        report_result(success, err, #batch)
    end
end

local function process_batches_timer(self, batches)
    local hdl, err = timer_at(0, process_batches, self, batches)
    if not hdl then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
    end
end

------------------------------------------------------------------
-- create a batch span processor.
--
-- @exporter            opentelemetry.trace.exporter.oltp
-- @opts                [optional]
--                          opts.drop_on_queue_full: if true, drop span when queue is full, otherwise force process batches, default true
--                          opts.max_queue_size: maximum queue size to buffer spans for delayed processing, default 2048
--                          opts.batch_timeout: maximum duration for constructing a batch, default 5s
--                          opts.inactive_timeout: timer interval for processing batches, default 2s
--                          opts.max_export_batch_size: maximum number of spans to process in a single batch, default 256
-- @return              processor
------------------------------------------------------------------
function _M.new(exporter, opts)
    if not opts then
        opts = {}
    end

    local drop_on_queue_full = true
    if opts.drop_on_queue_full ~= nil and not opts.drop_on_queue_full then
        drop_on_queue_full = false
    end

    local self = {
        exporter = exporter,
        drop_on_queue_full = drop_on_queue_full,
        max_queue_size = opts.max_queue_size or 2048,
        batch_timeout = opts.batch_timeout or 5,
        inactive_timeout = opts.inactive_timeout or 2,
        max_export_batch_size = opts.max_export_batch_size or 256,
        queue = {},
        first_queue_t = 0,
        batches_to_process = {},
        closed = false,
        dropping_count = 0,
    }
    self.maximum_pending_batches = math.floor(
        self.max_queue_size / self.max_export_batch_size) - 1

    assert(self.batch_timeout > 0)
    assert(self.inactive_timeout > 0)
    assert(self.max_export_batch_size > 0)
    assert(self.max_queue_size > self.max_export_batch_size)

    return setmetatable(self, mt)
end

function _M.on_end(self, span)
    if not span.ctx:is_sampled() or self.closed then
        return
    end

    -- Drop span if queue is full, otherwise add span to queue
    if self:get_queue_size() >= self.max_queue_size then
        if self.drop_on_queue_full then
            ngx.log(ngx.WARN, "queue is full, drop span: trace_id = ", span.ctx.trace_id, " span_id = ", span.ctx.span_id)
            report_dropped_spans(1, "buffer-full")
        end
    else
        table.insert(self.queue, span)
        if #self.queue == 1 then
            self.first_queue_t = now()
        end
    end

    -- Make a batch if batch timeout has been reached or queue >= batch size
    if now() - self.first_queue_t >= self.batch_timeout and #self.queue > 0 then
        table.insert(self.batches_to_process, self.queue)
        self.queue = {}
    elseif #self.queue >= self.max_export_batch_size then
        table.insert(self.batches_to_process, self.queue)
        self.queue = {}
    end

    -- Export if we've got enough batches. We want to export multiple batches
    -- simultaneously to reduce the number of ngx.timer.at calls, since they
    -- incur overhead.
    if #self.batches_to_process >= self.maximum_pending_batches then
        -- Move batch to process to a local variable so that there is not a race
        -- condition
        local batches_to_process = self.batches_to_process
        self.batches_to_process = {}

        -- process batches in background
        process_batches_timer(self, batches_to_process)
    end
end

function _M.shutdown(self)
    self:flush_all()
    self.closed = true
end

function _M.flush_all(self, with_timer)
    with_timer = with_timer or false

    if self.closed then
        return
    end

    if #self.queue > 0 then
        table.insert(self.batches_to_process, self.queue)
        self.queue = {}
    end

    if #self.batches_to_process == 0 then
        return
    end

    local batches_to_process = self.batches_to_process
    self.batches_to_process = {}

    if with_timer then
        process_batches_timer(self, batches_to_process)
    else
        process_batches(nil, self, batches_to_process)
    end
end

function _M.get_queue_size(self)
    return #self.queue + #self.batches_to_process * self.max_export_batch_size
end

return _M
