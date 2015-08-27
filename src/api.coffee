history = (req, res, next) ->
  console.log()
  res.send(200, {a: 1})
  next()

exports.history = history