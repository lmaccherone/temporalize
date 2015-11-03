DocumentDBMock = require('documentdb-mock')
path = require('path')
pbkdf2 = require('../mixins/pbkdf2')
randomBytes = require('../mixins/randomBytes')
#console.log(pbkdf2.toString())
#x = pbkdf2("S8OTug==", "CQcgCw==", 126, 12)
#
#console.log(x)
#
#salt = randomBytes(15).toString('base64')
#console.log(salt)
#
#for i in [0..100000]
#  x = Math.floor(Math.random() * 255)
#  if x > 255
#    console.log('whopse')
##console.log(salt, salt.length)

exports.postUserTest =

  storedProcTest: (test) ->
#    mock = new DocumentDBMock(path.join(__dirname, '..', 'sprocs', 'post-entity'))
#
#    authorization =
#      scheme: 'Basic'
#      credentials: 'some funky string'
#      basic:
#        username: 'admin'
#        password: 'admin-password'
#
#    user =
#      username: 'john@somewhere.com'
#      entityID: '1234'
#      salt: 'abcd'
#      hashedCredentials: 'something'
#      orgLinks: ['link1', 'link2']
#
#    mock.package({body: user, authorization})

#    test.equal(mock.lastBody.body.name, user.name)
#    test.equal(mock.rows.length, 1)
#    row = mock.rows[0]
#    test.deepEqual(row, user)
#    test.equal(row._ValidTo, "9999-01-01T00:00:00.000Z")

    test.done()