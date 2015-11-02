TODO: compile to js, and tests, and docs

simple window.fetch wrapper

```coffee
request = require 'clay-request'

# Automatic json extraction
request '/get'
.then (json) ->
  # parsed json

request '/post', {method: 'POST'}
.then (json) ->
  # parsed json

# Query string object support
request '/getQs', {qs: {a: 2}} # /getQs?a=2
.then (json) ->
  # parsed json

# Errors trigger promise failure
request '/404'
.catch (err) ->
  # RequestError object
  err.res.json().then -> # handle error

# RequestError
class RequestError extends Error
  constructor: ({res}) ->
    @name = 'RequestError'
    @message = res.statusText
    @stack = (new Error()).stack
    @res = res
```
