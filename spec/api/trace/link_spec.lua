local l = require("opentelemetry.api.trace.link")
local span_context = require("opentelemetry.api.trace.span_context")

describe("new", function()
    it("instantiates object correctly", function()
        local span_ctx = span_context.new()
        local attrs = { foo = "bar" }
        local link = l.new(span_ctx, attrs)
        assert.are_equal(span_ctx, link.span_context)
        assert.are_equal(attrs, link.attributes)
    end)
end)
