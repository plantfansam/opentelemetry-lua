require("spec.api.spec_helper")

local context = require("opentelemetry.api.context")
local span = require("opentelemetry.api.trace.span")

describe("context", function()
    before_each(function()
        __OTEL.context_storage = {}
    end)

    describe("get and set", function()
        it("stores and retrieves values at given key", function()
            local ctx = context.new()
            local new_ctx = ctx:set("key", "value")
            assert.are.equal(new_ctx:get("key"), "value")
            assert.are_not.equal(ctx, new_ctx)
        end)
    end)

    describe("current", function()
        it("returns last element stored in stack at context_key", function()
            local ctx_1 = context.new({ foo = "bar" })
            local ctx_2 = context.new({ foo = "baz" })
            __OTEL.context_storage = { __opentelemetry_context__ = { ctx_1, ctx_2 } }
            assert.are.equal(ctx_2, context.current())
        end)
    end)

    describe("attach", function()
        it(
            "creates new table at context_key if no table present and returns token matching length of stack after adding element",
            function()
                local ctx = context.new({ foo = "bar" })
                local token = ctx:attach()
                assert.are.equal(token, 1)
            end)

        it("appends to existing table at context_key", function()
            local ctx_1 = context.new({ foo = "bar" })
            local ctx_2 = context.new({ foo = "baz" })
            local token_1 = ctx_1:attach()
            local token_2 = ctx_2:attach()
            assert.are.equal(token_1, 1)
            assert.are.equal(token_2, 2)
        end)
    end)

    describe("detach", function()
        it("removes final context from stack at context_key", function()
            local ctx = context.new()
            local token = ctx:attach()
            local outcome, err = ctx:detach(token)
            assert.is_true(outcome)
            assert.is_nil(err)
        end)

        it("returns outcome of 'false' and error string if token does not match", function()
            local ctx = context.new()
            ctx:attach()
            local outcome = ctx:detach(2)
            assert.is_false(outcome)
        end)
    end)

    describe("span", function()
        it("returns contents of span key", function()
            local span = span.new()
            local ctx = context.with_span(span)
            assert.are_equal(span, ctx:span())
        end)
    end)

    describe("with_span", function()
        it("puts span on span_key in context storage", function()
            local span = span.new()
            local ctx = context.with_span(span)
            ctx:attach()
            assert.are_equal(span, ctx:span())
            assert.are_equal(span, context.span_from_context())
        end)
    end)
end)

describe("inject and extract baggage", function()
    it("adds baggage to context and extracts it", function()
        local ctx = context.new(storage)
        local baggage = { hi = 'buddy' }
        local new_ctx = ctx:inject_baggage(baggage)
        assert.are.same(new_ctx:extract_baggage(), baggage)
    end)
end)

describe("current_span()", function()
    it("returns span stored on current context when it exists", function()
        __OTEL.context_storage = {}
        -- TODO replace span mock with actual span from API
        local span = {
            context = {
                is_valid = function()
                    return true
                end
            }
        }
        local ctx = context.with_span(span)
        ctx:attach()
        assert.are_equal(context.span_from_context(), span)
    end)
end)
