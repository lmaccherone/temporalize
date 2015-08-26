hello = (req, res, next) ->
  res.send(200, {a: 1})
  next()

exports.hello = hello