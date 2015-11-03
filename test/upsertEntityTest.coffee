DocumentDBMock = require('documentdb-mock')
path = require('path')
documentdb = require('documentdb')

exports.upsertEntityTest =

  basicTest: (test) ->
    mock = new DocumentDBMock(path.join(__dirname, '..', 'mixins', 'upsertEntity'))

    user =
      _EntityID: documentdb.Base.generateGuidId()
      "username": "admin@somewhere.com"
      "salt": "abcd"
      "hashedCredentials": "something"
      "orgIDsThisUserCanRead": ["ID1", "ID2", "ID3"]
      "orgIDsThisUserCanWrite": ["ID1", "ID2"]
      "orgIDsThisUserIsAdmin": ["ID1"]

    mock.nextResources = [user]

    entityTypes = ["Story"]
    newRevisionOfEntity =
      a: 10
    authorization =
      scheme: 'Basic'
      credentials: 'something'
      basic:
        username: 'admin@somewhere.com'
        password: 'admin'
    authorizationFunction = (userMakingRequest, orgID) ->
      console.log(userMakingRequest, orgID)
      return true

    test.throws(() ->
      mock.package(newRevisionOfEntity, authorization, authorizationFunction)
    )

    newRevisionOfEntity._OrgID = 'ID1'
    result = mock.package(newRevisionOfEntity, authorization, authorizationFunction)  # Since this is a mixin, it has more than just a single memo parameter
    test.deepEqual(mock.lastBody.user, user)


    test.done()