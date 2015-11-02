b = require 'b-assert'
zock = require 'zock'

request = require '../src'

it 'requests', ->
  zock
    .base 'http://example.com'
    .get '/test'
    .reply (req) ->
      b req.body, {bb: 'cc'}
      b req.query, {xxx: 'yyy'}
      {a: 'b'}
    .post '/test'
    .reply (req) ->
      b req.body, {cc: 'dd'}
      b req.query, {yyy: 'xxx'}
      {c: 'd'}
    .withOverrides ->
      request 'http://example.com/test',
        method: 'get'
        body: {bb: 'cc'}
        qs: {xxx: 'yyy'}
      .then (res) ->
        b res, {a: 'b'}
        request 'http://example.com/test',
          method: 'post'
          body: {cc: 'dd'}
          qs: {yyy: 'xxx'}
      .then (res) ->
        b res, {c: 'd'}

it 'handles errors', ->
  zock
    .base 'http://example.com'
    .get '/test'
    .reply 400, {err: 'err'}
    .withOverrides ->
      request 'http://example.com/test'
      .then ->
        throw new Error 'expected error'
      , (err) ->
        b err.name, 'RequestError'
        err.res.json()
        .then (json) ->
          b json, {err: 'err'}
