_ = require 'lodash'
Qs = require 'qs'

Promise = if window?
  window.Promise
else
  # Avoid webpack include
  _Promise = 'bluebird'
  require _Promise

fetch = if window?
  window.fetch
else
  # Avoid webpack include
  _fetch = 'node-fetch'
  fetch = require _fetch
  fetch.Promise = Promise
  fetch

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

statusCheck = (response) ->
  if response.status >= 200 and response.status < 300
    Promise.resolve response
  else
    Promise.reject response

toJson = (response) ->
  if response.headers.get('Content-Type') is 'application/json'
    if response.status is 204
    then null
    else response.json()
  else
    response.text()

module.exports = (url, options) ->
  if _.isObject options?.body or _.isArray options?.body
    options.headers = _.defaults (options.headers or {}),
      'Accept': 'application/json'
      'Content-Type': 'application/json'
    options.body = JSON.stringify options.body

  if _.isObject options?.qs
    url += '?' + Qs.stringify options.qs

  fetch url, options
  .then statusCheck
  .then toJson
  .catch (err) ->
    if err.ok?
      throw new RequestError {res: err}
    else
      throw err
