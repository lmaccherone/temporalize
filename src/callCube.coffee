{OLAPCube, Time, csvStyleArray_To_ArrayOfMaps, table, functions} = require('lumenize')

hello = (req, res, next) ->
  res.send(200, {a: 1})
  next()

exports.hello = hello