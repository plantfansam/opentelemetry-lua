local traceflags = require("lib.opentelemetry.api.trace.traceflags")

describe("new()", function()
    it("defaults to 00", function()
        local tf = traceflags.new()
        assert.are_same("00", tf.hex_byte)
    end)
end)
