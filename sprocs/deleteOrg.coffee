exports.deleteOrg = (memo) ->

  ###* @require: {"toRequireString": "sql-from-mongo", "functionName": "sqlFromMongo"} ###

  collection = getContext().getCollection()

  unless memo?.org?
    throw new Error('Must pass in memo.org to deleteOrd stored procedure.')

  mongoQueryObject = {"_Org": memo.org}
  queryString = 'SELECT * FROM c WHERE ' + sqlFromMongo(mongoQueryObject)

  memo.stillQueueing = true

  query = () ->
    if stillQueuingOperations
      responseOptions =
        pageSize: memo.remaining
      setBody()
      memo.stillQueuing = collection.queryDocuments(collection.getSelfLink(), queryString, responseOptions, onReadDocuments)

  onReadDocuments = (err, resources, options) ->
    if err
      throw err

    if resources.length isnt memo.remaining
      throw new Error("Expected memo.remaining (#{memo.remaining}) and the number of rows returned (#{resources.length}) to match. They don't.")

    memo.stillQueueing = true
    while memo.remaining > 0 and memo.stillQueueing
      oldDocument = resources[memo.remaining - 1]
      documentLink = oldDocument._self
      etag = oldDocument._etag
      options = {etag}  # Sending the etag per best practice, but not handling it if there is conflict.
      getContext().getResponse().setBody(memo)
      memo.stillQueueing = collection.deleteDocument(documentLink, options)
      if memo.stillQueueing
        memo.remaining--

  setBody = () ->
    getContext().getResponse().setBody(memo)

  query()
  return memo
