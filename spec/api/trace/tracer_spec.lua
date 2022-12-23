require("spec.api.spec_helper")

local context = require("opentelemetry.api.context")
local span = require("opentelemetry.api.trace.span")
local span_context = require("opentelemetry.api.trace.span_context")
local tracer = require("opentelemetry.api.trace.tracer")

describe("start_span()", function()
    it("returns empty, non-recording span when current context is empty", function()
        -- TODO replace span mock with actual span from API
        __OTEL.context_storage = {}
        local t = tracer.new()
        local span = t:start_span("foobar")
        assert.is_false(span:is_recording())
        assert.is_false(span:get_span_context():is_valid())
    end)

    it("returns nonrecording span derived from current span context when span is present on context", function()
        __OTEL.context_storage = {}
        local old_sc = span_context.new("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "aaaaaaaaaaaaaaaa")
        local s = span.from_span_context(old_sc)
        stub(s, "is_recording", function()
            return true
        end)
        local ctx = context.with_span(s)
        ctx:attach()

        local t = tracer.new()
        local new_sp = t:start_span("foobar")
        local new_sc = new_sp:get_span_context()

        s.is_recording:revert()
        assert.are_same(old_sc.trace_id, new_sc.trace_id)
        assert.are_same(old_sc.span_id, new_sc.span_id)
        assert.are_same(old_sc.trace_flags, new_sc.trace_flags)
        assert.are_same(old_sc.tracestate, new_sc.tracestate)
    end)

    it("returns nonrecording span derived from parent span context, when arg is passed", function()
        __OTEL.context_storage = {}
        local old_sc = span_context.new("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "aaaaaaaaaaaaaaaa")
        local s = span.from_span_context(old_sc)
        stub(s, "is_recording", function()
            return true
        end)
        local ctx = context.with_span(s)
        local t = tracer.new()
        local new_sp = t:start_span("foobar", ctx)
        local new_sc = new_sp:get_span_context()

        s.is_recording:revert()
        assert.are_same(old_sc.trace_id, new_sc.trace_id)
        assert.are_same(old_sc.span_id, new_sc.span_id)
        assert.are_same(old_sc.trace_flags, new_sc.trace_flags)
        assert.are_same(old_sc.tracestate, new_sc.tracestate)
    end)

    it("returns span from current context if it's nonrecording", function()
        __OTEL.context_storage = {}
        local old_sc = span_context.new("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "aaaaaaaaaaaaaaaa")
        local s = span.from_span_context(old_sc)
        local ctx = context.with_span(s)
        ctx:attach()
        local t = tracer.new()
        local new_sp = t:start_span("foobar")
        local new_sc = new_sp:get_span_context()

        assert.is_false(s:is_recording())
        assert.are_same(s, new_sp)
    end)
end)
