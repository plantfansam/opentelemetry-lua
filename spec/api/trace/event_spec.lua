local e = require("opentelemetry.api.trace.event"):new()

describe("new", function()
    it("instantiates object correctly", function()
        local name = "foobar"
        local attrs = { foo = "bar" }
        local timestamp = 1234
        local event = e.new(name, attrs, timestamp)
        assert.are_equal(event.name, name)
        assert.are_equal(event.attributes, attrs)
        assert.are_equal(event.timestamp, timestamp)
    end)
end)
