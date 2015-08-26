class RestifyMock

  constructor: () ->
    @responses = []
    @lastResponseBody = null

    @req = null

    @res =
      send: (code, body) =>
        unless body?
          body = code
          code = null
        @responses.push({code, body})
        @lastResponseBody = body

    @next = () ->
      return

exports.RestifyMock = RestifyMock