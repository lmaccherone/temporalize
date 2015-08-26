restify = require("restify")

hello = require("./src/hello")
write = require("./src/write")

port = process.env.PORT or 1338

logResponseCallback = (err, response) ->
  console.log(response)

server = restify.createServer()

server.get("/hello", hello.hello)
server.post("/batch", write.batch)
#server.post("/entity:entityID", write.entity)

server.listen(port, () ->
  console.log("%s listening at %s", server.name, server.url)
)
