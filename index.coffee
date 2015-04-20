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


statusCheck = (response) ->
  if response.status >= 200 and response.status < 300
    Promise.resolve response
  else
    Promise.reject response

toJson = (response) ->
  if response.status is 204 then null else response.json()

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
    if err?.json
      err.json().then (error) ->
        throw error
    else
      throw err
