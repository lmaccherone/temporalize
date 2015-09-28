# TODO: Upgrade to accept parameters for databaseID and collectionID
# TODO: Then, move this to documentdb-utils
path = require('path')
fs = require('fs')
documentDBUtils = require('documentdb-utils')
{DoublyLinkedList} = require('doubly-linked-list')


insertMixins = (sproc, minify = false) ->
  # TODO: Minify resulting string if specified
  switch typeof(sproc)
    when 'function'
      sprocString = sproc.toString()
    when 'string'
      sprocString = sproc
  
  keyString = "= require("
  sprocLines = sprocString.split('\n')
  list = new DoublyLinkedList(sprocLines)
  current = list.head
  while current?
    keyIndex = current.value.indexOf(keyString)
    if keyIndex >= 0
      variableString = current.value.substr(0, keyIndex).trim()
      toRequireString = current.value.substr(keyIndex + keyString.length + 1)
      toRequireString = toRequireString.substr(0, toRequireString.indexOf("'"))
      functionToInsert = require(toRequireString)
      unless typeof(functionToInsert) is 'function'
        functionToInsert = functionToInsert[variableString]
      functionToInsertString = "  var " + variableString + " = " + functionToInsert.toString() + ';\n'
      current.value = functionToInsertString
    current = current.after

  sprocString = list.toArray().join('\n')

  if minify
    console.log('Minify not implemented yet')

  return sprocString

loadSprocFromFile = (sprocFile, callback) ->
  sproc = require(sprocFile)
  sprocName = path.basename(sprocFile, '.coffee')
  unless typeof(sproc) is 'function'
    sproc = sproc[sprocName]

  sprocString = insertMixins(sproc.toString())

  if sprocName is 'deleteOrg'
    console.log(sprocString)

  config =
    databaseID: 'test-stored-procedure'  # TODO: Need to parameterize this. What do we do when we have more than one db?
    collectionID: 'test-stored-procedure'
    storedProcedureID: sprocName
    storedProcedureJS: sprocString
    memo: null
  documentDBUtils(config, (err, response) ->
    if err?
      throw new Error(err)
    else
      callback(sprocName, response.storedProcedureLink)
  )

getHandler = (storedProcedureLink, storedProcedureName) ->
  handler = (req, res, next) ->
    config =
      storedProcedureLink: storedProcedureLink
      # Note, the line below assumes that the body/queryParser uses mapParams = false
      memo: {params: req.params, query: req.query, body: req.body, authorization: req.authorization}
      debug: true

    documentDBUtils(config, (err, response) ->
      if err?
        console.log('Error', err)
      next.ifError(err)
      toReturn =
        memo: response.memo
        stats: response.stats
      res.send(200, toReturn)
      next()
    )
  return handler

module.exports = (sprocDirectory, server, callback) ->
  sprocLinks = {}
  sprocFiles = fs.readdirSync(sprocDirectory)
  fullSprocFiles = []
  for sprocFile in sprocFiles
    fullFilePath = path.join(sprocDirectory, sprocFile)
    fullSprocFiles.push(fullFilePath)

  loadOneSproc = (callback) ->
    if fullSprocFiles.length > 0
      sprocFile = fullSprocFiles.pop()
      loadSprocFromFile(sprocFile, (sprocName, sprocLink) ->
        sprocLinks[sprocName] = sprocLink
        dashIndex = sprocName.indexOf('-')
        routeMethod = sprocName.substr(0, dashIndex)
        routeEntity = sprocName.substr(dashIndex + 1)
        handler = getHandler(sprocLink, sprocName)
        switch routeMethod
          when 'del', 'put'
            server.del('/' + routeEntity + '/:id', handler)
          when 'get'
#            server.get('/' + routeEntity + '/:id', handler)
            server.get('/' + routeEntity, handler)
          when 'post'
            server.post('/' + routeEntity, handler)
          else
            console.log('Warning, unrecognized routeMethod: ' + routeMethod + 'for ' + sprocName)
        if fullSprocFiles.length > 0
          loadOneSproc(callback)
        else
          server.locals.sprokLinks = sprocLinks
          callback()
      )

  loadOneSproc(callback)
