require("spec.api.spec_helper")

local span_context = require("opentelemetry.api.trace.span_context")
local traceflags = require("opentelemetry.api.trace.traceflags")

describe("new()", function()
    it("instantiates new tracestate and traceflags if not supplied", function()
        local sc = span_context.new()
        assert.is_not_nil(sc.trace_state)
        assert.is_not_nil(sc.traceflags)
    end)
end)

describe("is_sampled()", function()
    it("returns true when traceflags are 01", function()
        local sc = span_context.new("12345678123456781234567812345678", "1234576812345678", traceflags.new("01"))
        assert.is_true(sc:is_sampled())
    end)

    it("returns false when traceflags are 00", function()
        local sc = span_context.new("12345678123456781234567812345678", "1234576812345678", traceflags.new("00"))
        assert.is_false(sc:is_sampled())
    end)
end)

describe("is_valid", function()
    it("returns true if span id and trace id are nonzero", function()
        local sc = span_context.new("12345678123456781234567812345678", "1234576812345678")
        assert.is_true(sc:is_valid())
    end)

    it("returns false if span id or trace id is zero", function()
        local sc = span_context.new("12345678123456781234567812345678", span_context.non_recording_span_ID)
        assert.is_false(sc:is_valid())

        local sc = span_context.new(span_context.INVALID_TRACE_ID, "1234567812345678")
        assert.is_false(sc:is_valid())
    end)
end)
