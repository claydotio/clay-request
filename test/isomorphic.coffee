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

it 'only defaults headers (and stringify\'s body) if plain object', ->
  zock
    .base 'http://example.com'
    .post '/testJSON'
    .reply (req) ->
      b req.headers.xx, 'yy'
      b req.headers['accept'] or req.headers['Accept'],
        'application/json'
      b req.headers['content-type'] or req.headers['Content-Type'],
        'application/json'
      b req.body, {cc: 'dd'}
      {c: 'd'}
    .post '/testJSONArray'
    .reply (req) ->
      b req.headers['accept'] or req.headers['Accept'],
        'application/json'
      b req.headers['content-type'] or req.headers['Content-Type'],
        'application/json'
      b req.body, ['zz']
      {c: 'd'}
    .post '/testPlain'
    .reply (req) ->
      b req.headers.xx, 'yy'
      b req.headers['accept'] isnt 'application/json'
      b req.headers['content-type'] isnt 'application/json'
      b req.body, 'plaintext'
      {c: 'd'}
    .withOverrides ->
      request 'http://example.com/testJSON',
        method: 'post'
        body: {cc: 'dd'}
        headers:
          xx: 'yy'
      .then (res) ->
        b res, {c: 'd'}
        request 'http://example.com/testJSONArray',
          method: 'post'
          body: ['zz']
      .then (res) ->
        b res, {c: 'd'}
        request 'http://example.com/testPlain',
          method: 'post'
          body: 'plaintext'
          headers:
            xx: 'yy'
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
