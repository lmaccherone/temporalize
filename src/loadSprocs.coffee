# TODO: Upgrade to accept parameters for databaseID and collectionID
# TODO: Then, move this to documentdb-utils
path = require('path')
fs = require('fs')
documentDBUtils = require('documentdb-utils')

insertMixins = (sproc, minify = false) ->
  # TODO: Minify resulting string if specified
  switch typeof(sproc)
    when 'function'
      sprocString = sproc.toString()
    when 'string'
      sprocString = sproc
  
  annotationStartString = '/** @require:'
  annotationEndString = '*/'
  annotationStartIndex = sprocString.indexOf(annotationStartString)
  if annotationStartIndex >= 0
    startIndex = annotationStartIndex + annotationStartString.length
    endIndex = sprocString.indexOf(annotationEndString)
    requireSpecString = sprocString.substr(startIndex, endIndex - startIndex)
    requireSpec = JSON.parse(requireSpecString)
    functionToInsert = require(requireSpec.toRequireString)
    unless typeof(functionToInsert) is 'function'
      functionToInsert = functionToInsert[requireSpec.functionName]
    functionToInsertString = functionToInsert.toString()

    unless minify
      # TODO: Add the correct spaces. For now assuming 2.
      functionRows = functionToInsertString.split('\n')
      spacedFunctionRows = []
      for row, index in functionRows
        if index is 0
          spacedFunctionRows.push(row)
        else
          spacedFunctionRows.push('  ' + row)
      functionToInsertString = spacedFunctionRows.join('\n')

    beforeString = sprocString.substr(0, annotationStartIndex)
    afterString = sprocString.substr(endIndex + annotationEndString.length)
    sprocString = beforeString + functionToInsertString + '\n' + afterString

  annotationStartIndex = sprocString.indexOf(annotationStartString)
  if annotationStartIndex >= 0
    insertMixins(sprocString)
  else
    if minify
      console.log('Minify not implemented yet')
    return sprocString

loadSprocFromFile = (sprocFile, callback) ->
  sproc = require(sprocFile)
  sprocName = path.basename(sprocFile, '.coffee')
  unless typeof(sproc) is 'function'
    sproc = sproc[sprocName]

  sprocString = insertMixins(sproc.toString())

  config =
    databaseID: 'test-stored-procedure'  # TODO: Need to parameterize this. What do we do when we have more than one db?
    collectionID: 'test-stored-procedure'
    storedProcedureID: sprocName
    storedProcedureJS: sproc
    memo: null
  documentDBUtils(config, (err, response) ->
    if err?
      throw new Error(err)
    else
      callback(sprocName, response.storedProcedureLink)
  )

module.exports = (sprocDirectory, callback) ->
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
        if err?
          throw new Error(err)
        else
          sprocLinks[sprocName] = sprocLink
          if fullSprocFiles.length > 0
            loadOneSproc(callback)
          else
            callback(sprocLinks)
      )

  loadOneSproc(callback)
