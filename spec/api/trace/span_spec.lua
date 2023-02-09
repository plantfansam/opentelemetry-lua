local span = require("opentelemetry.api.trace.span")
local span_context = require("opentelemetry.api.trace.span_context")
local traceflags = require("opentelemetry.api.trace.traceflags")

describe("new()", function()
    it("initializes new span context if none is supplied", function()
        local span = span:new()
        assert.is_not_nil(span.span_context)
    end)
end)

describe("get_context()", function()
    it("initializes new span context if none is supplied", function()
        local sc = span_context.new()
        local span = span:new(sc)
        assert.are_equal(span:get_span_context(), sc)
    end)
end)

describe("is_recording()", function()
    it("always returns false, even if span context indicates that span is sampled", function()
        local sc = span_context.new("traceid", "spanid", traceflags.new("01"))
        assert.is_true(sc:is_sampled())
        local span = span:new(sc)
        assert.is_false(span:is_recording())
    end)
end)
