# README

This folder contains an implementation of OpenTelemetry's API. All operations effectively no-op unless the program registers an SDK. For more on the API/SDK distinction, check out the [documentation](https://opentelemetry.io/docs/reference/specification/overview/#api).

```
----- Near the top of your program -----
Opentelemetry = require("opentelemetry")
local tracer_provider_new = require("opentelemetry.sdk.trace.tracer_provider.new")
Opentelemetry.tracer_provider = tracer_provider_new()

-- local tracer = Opentelemetry.tracer_provider.tracer("my-cool-tracer")
local sp = Opentelemetry.tracer.start("hi")
sp.end()
```

## Dev dependencies

`lua-formatter`, `busted`, `ldoc`.

## Running tests

Run `busted -m "./lib/?.lua;./lib/?/?.lua;./lib/?/?/?.lua" spec/api` from root of repository.

Run a single test by adding `#now` (or another tag of your choosing) to the test description `it("foo bar #now")` and then running `busted -m "./lib/?.lua;./lib/?/?.lua;./lib/?/?/?.lua" -t "now" spec/api`

## Generating docs

`ldoc lib/opentelemetry/api && open docs/index.html`

## Formatting

We use [`lua-formatter`](https://github.com/Koihik/LuaFormatter) to format the code.

## Principles, in loose order

* Don't cause runtime errors
* Run as fast as possible
* Test well
* Document well
* Include as few runtime dependencies as possible
* Make it easy to contribute
