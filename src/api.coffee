postSnapshots = (req, res, next) ->
  # !TODO: Need to confirm that this user has write permission for the _Org that they specified.
  for row in req.body.snapshots
    row._Org = req.body._Org

  console.log('hello')
  res.send(200, {a: 1})
  next()

exports.postSnapshots = postSnapshots