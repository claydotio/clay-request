TODO: compile to js, and tests, and docs

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

# Error trigger promise failure
request '/404'
.catch (err) ->
  # RequestError object
  
# RequestError
class RequestError extends Error
  constructor: ({res}) ->
    @type = res.type
    @url = res.url
    @status = res.status
    @ok = res.ok
    @statusText = res.statusText
    @headers = res.headers
    @bodyUsed = res.bodyUsed
    @arrayBuffer = res.arrayBuffer
    @blob = res.blob
    @formData = res.formData
    @json = res.json
    @text = res.text

    @name = 'RequestError'
    @message = res.statusText
    @stack = (new Error()).stack
```
