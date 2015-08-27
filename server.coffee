restify = require("restify")

hello = require("./src/hello")
api = require("./src/api")

port = process.env.PORT or 1338

logResponseCallback = (err, response) ->
  console.log(response)

server = restify.createServer(
  name: 'temporalize'
  version: "0.1.0"
)

server.get("/hello", hello.hello)
server.post("/history", api.history)
#server.post("/entity:entityID", write.entity)

server.listen(port, () ->
  console.log("%s listening at %s", server.name, server.url)
)
