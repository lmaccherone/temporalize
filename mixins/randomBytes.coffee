module.exports = (count) ->
  buffer = new Buffer(count)
  for i in [0..count]
    buffer[i] = Math.floor(Math.random() * 255)

  return buffer