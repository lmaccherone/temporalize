module.exports = (memo) ->

  # Check input and initialize
  unless memo?.snapshots?
    throw new Error('secondSproc must be called with an object containing a `snapshots` field.')
  unless memo.totalCount?
    memo.totalCount = 0
  memo.countForThisRun = 0

  collection = getContext().getCollection()
  collectionLink = collection.getSelfLink()
  memo.stillQueueing = true

  writeSnapshot = () ->
    if memo.documents.length > 0 and memo.stillQueueing
      doc = memo.snapshots.pop()
      getContext().getResponse().setBody(memo)
      memo.stillQueueing = collection.createDocument(collectionLink, doc, (error, resource, options) ->
        if error?
          throw new Error(error)
        else if memo.stillQueueing
          memo.countForThisRun++
          memo.totalCount++
          writeSnapshot()
        else
          memo.snapshots.push(doc)
          memo.continuation = "value does not matter"
          getContext().getResponse().setBody(memo)
      )
    else
      memo.continuation = null
      getContext().getResponse().setBody(memo)

  writeSnapshot()
