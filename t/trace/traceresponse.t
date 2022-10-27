use Test::Nginx::Socket 'no_plan';

log_level('debug');
repeat_each(1);
no_long_string();
no_root_location();
run_tests();

__DATA__

=== TEST 1: traceresponse headers inserted correctly
--- config
location = /t {
    content_by_lua_block {
        local context = require("opentelemetry.context")
        local span_context = require("opentelemetry.trace.span_context")
        local trp = require("opentelemetry.trace.propagation.text_map.trace_response_propagator")
        -- Normally, we'd run traceresponse_propagator:extract against headers returned from the upstream service, but for this test, we'll just create a span context manually.
        local span_ctx = span_context.new("0000000000000001", "00000001", 1, "", true)
        local new_ctx = context.new():with_span_context(span_ctx)
        trp.new():inject(new_ctx, ngx)
        ngx.log(ngx.ERR, ngx.header["traceresponse"])
     }
}
--- request
GET /t
--- response_headers
traceresponse: 00-0000000000000001-00000001-1
