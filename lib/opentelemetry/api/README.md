# README

This folder contains an in-progress implementation of OpenTelemetry's API. All operations effectively no-op unless the program registers an SDK. For more on the API/SDK distinction, check out the [documentation](https://opentelemetry.io/docs/reference/specification/overview/#api).

## Usage

Get a tracer:

```lua
local tracer_provider = require("opentelemetry.api.trace.tracer_provider" ):new()
local tracer = tracer_provider:get("tracername", "0.1", "http://schema-url.com", {})
```

### Dev dependencies

`lua-formatter`, `busted`, `ldoc`.

### Running tests

Run `make api-test` from root of repository.

Run a single test by adding `#now` (or another tag of your choosing) to the test description `it("foo bar #now")` and then running `busted -m "./lib/?.lua;./lib/?/?.lua;./lib/?/?/?.lua" -t "now" spec/api`

### Generating docs

`make doc`

### Formatting

`make format` (we use [`lua-formatter`](https://github.com/Koihik/LuaFormatter) to format the code).
