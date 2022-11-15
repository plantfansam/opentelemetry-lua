local tracestate = require("opentelemetry.trace.tracestate")

describe("is_valid", function()
    it("parse, get works", function()
        local ts = tracestate.parse_tracestate("foo=bar,baz=lehrman")
        assert.is_true(#ts == 2)
        assert.is_true(ts:get("foo") == "bar")
        assert.is_true(ts:get("baz") == "lehrman")
    end)
    it("set works", function()
        local ts = tracestate.parse_tracestate("foo=bar,baz=lehrman")
        assert.is_true(#ts == 2)
        ts:set("foo", "fun")
        assert.is_true(#ts == 2)
        assert.is_true(ts:get("foo") == "fun")
        ts:set("family", "values")
        assert.is_true(#ts == 3)
        assert.is_true(ts:get("family") == "values")
    end)
    it("del works", function()
        local ts = tracestate.parse_tracestate("foo=bar,baz=lehrman")
        ts:del("foo")
        assert.is_true(#ts == 1)
        assert.is_true(ts:get("foo") == "")
    end)
    it("as_string works", function()
        local ts = tracestate.parse_tracestate("foo=bar,baz=lehrman")
        assert.is_true(ts:as_string() == "foo=bar,baz=lehrman")
        ts:set("bing", "bong")
        assert.is_true(ts:as_string() == "bing=bong,foo=bar,baz=lehrman")
    end)
    it("max len is respected", function()
        local ts = tracestate.parse_tracestate("")
        for i=1,tracestate.MAX_ENTRIES,1 do
            ts:set("a" .. tostring(i), "b" .. tostring(i))
        end
        assert.is_true(#ts == tracestate.MAX_ENTRIES)
        ts:set("one", "more")
        assert.is_true(#ts == tracestate.MAX_ENTRIES)
        -- First elem added is the first one lost when we add over max entries
        assert.is_true(ts:get("a1") == "")
        assert.is_true(ts:get("one") == "more")
        -- Newest elem is prepended
        assert.is_true(ts[1] == "one=more")

    end)
end)