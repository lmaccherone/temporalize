api = require('../src/api')
{RestifyMock} = require('../src/RestifyMock')
mock = new RestifyMock()

exports.snapshotsTest =

  postSnapshots: (test) ->

    api.postSnapshots(mock.req, mock.res, mock.next)

    test.deepEqual(mock.responses[0].body, {a: 1})
    test.deepEqual(mock.lastResponseBody, {a: 1})

    test.done()