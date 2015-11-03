restify = require('restify')
documentdb = require('documentdb')

exports.postEntityTestLive =

  upsertEntity: (test) ->

    client = restify.createJsonClient({
      url: 'http://localhost:1338',
      version: '*'
    })
    client.basicAuth('admin@somewhere.com', 'admin')

    user =
      _EntityID: documentdb.Base.generateGuidId()
      "username": "admin@somewhere.com"
      "salt": "abcd"
      "hashedCredentials": "something"
      "orgIDsThisUserCanRead": ["ID1", "ID2", "ID3"]
      "orgIDsThisUserCanWrite": ["ID1", "ID2"]
      "orgIDsThisUserIsAdmin": ["ID1"]

    authorizationFunction = (userMakingRequest, orgID) ->
      memo.log = "userMakingRequest: #{userMakingRequest}, orgID: #{orgID}"
      return true

    username = 'admin@somewhere.com'
    password = "admin"

    client.basicAuth(username, password)

    body =
      _OrgID: documentdb.Base.generateGuidId()
      field1: 'value1'
      field2: 2

    # TODO: Create user for this test. Don't assume that admin@somewhere.com is a user.
    client.post('/entity', body, (err, req, res, obj) ->
      if err?
        console.log(JSON.stringify(err))
        throw new Error(JSON.stringify(err))

#      console.log('obj.memo', obj.memo)
      user = obj.memo.user
      test.equal(user._IsTEMPORALIZE_USER, true)
      test.equal(user.username, username)
      test.ok(not user.salt?)
      test.ok(not user.hashedCredentials?)
      test.ok(not user._rid?)
      test.ok(not user._ts?)
      test.ok(not user._self?)
      test.ok(not user._attachments?)

      test.done()
    )