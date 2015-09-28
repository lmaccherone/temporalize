documentDBUtils = require('documentdb-utils')

exports.postSnapshots = (req, res, next) ->
  # !TODO: Need to confirm that this user has write permission for the orgId that they specified.
  snapshots = req.body.snapshots
  orgId = req.body.orgId
  storedProcedureLink = @locals.sprocLinks.postSnapshot
  config =
    storedProcedureLink: storedProcedureLink
    memo: {orgId, snapshots}
#    debug: true

  documentDBUtils(config, (err, response) ->
    if err?
      throw new Error(JSON.stringify(err))
    else
      res.send(200, response)
      next()
  )

exports.getSnapshots = (req, res, next) ->
# !TODO: Need to add an "$and" clause so that only this user's orgId is used

  documentDBUtils(config, (err, response) ->
    if err?
      throw new Error(JSON.stringify(err))
    else
      res.send(200, response)
      next()
  )

exports.deleteOrg = (req, res, next) ->
  # !TODO: Need to confirm that this user has permission to delete the _Org that they specified.
  org = req.params.org

  storedProcedureLink = @locals.sprocLinks.deleteOrg
  config =
    storedProcedureLink: storedProcedureLink
    memo: {org}
  #    debug: true

  documentDBUtils(config, (err, response) ->
    if err?
      throw new Error(JSON.stringify(err))
    else
      res.send(200, response)
      next()
  )