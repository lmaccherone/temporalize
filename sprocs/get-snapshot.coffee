# !TODO: Need to confirm that this user has write permission for the orgId that they specified.
module.exports = (memo) ->
  ###* @require: {"toRequireString": "sql-from-mongo", "functionName": "sqlFromMongo"} ###
  sqlFromMongo = require('sql-from-mongo')

  collection = getContext().getCollection()

  unless memo.continuation?
    memo.continuation = null

  queryString = 'SELECT c._self, c._etag FROM c WHERE ' + sqlFromMongo.sqlFromMongo(memo.query.query, 'c')

  memo.stillQueueing = true
  memo.snapshots = []
  memo.count = 0

  setBody = () ->
    getContext().getResponse().setBody(memo)

  queryOnePage = () ->
    if memo.stillQueueing
      responseOptions =
        continuation: memo.continuation
        pageSize: 1000
      setBody()
      memo.stillQueueing = collection.queryDocuments(collection.getSelfLink(), queryString, responseOptions, onReadDocuments)

  onReadDocuments = (err, resources, options) ->
    if err
      throw err

    # TODO: Need to upgrade documentDBUtils so it that I can pass back one big batch after another and not have them come back in the memo.
    # For now, just going to error if it the sproc times out. Should get me at least 10,000 documents.
    if not memo.stillQueueing and options.continuation
      throw "Query results in too many rows. Provide a more selective query."

    if options.continuation?
      memo.continuation = options.continuation
    else
      memo.continuation = null
    memo.snapshots = memo.snapshots.concat(resources)
    memo.count = memo.snapshots.length

    setBody()
    if memo.stillQueueing and memo.continuation?
      queryOnePage()

  queryOnePage()
  return memo
