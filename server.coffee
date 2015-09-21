restify = require("restify")
fs = require('fs')
path = require('path')

hello = require("./src/hello")
api = require("./src/api")
loadSprocs = require("./src/loadSprocs")

port = process.env.PORT or 1338
sprocLinks = {}

loadServer = () ->
  logResponseCallback = (err, response) ->
    console.log(response)

  server = restify.createServer(
    name: 'temporalize'
    version: "0.1.0"
  )

  server.use(restify.authorizationParser())
  server.use(restify.bodyParser())
  server.use(restify.queryParser())
  server.get("/hello", hello.hello)
  server.post("/snapshots", api.postSnapshots)
  #server.post("/entity:entityID", write.entity)

  server.listen(port, () ->
    console.log("%s listening at %s", server.name, server.url)
  )

sprocDirectory = path.join(__dirname, 'sprocs')
loadSprocs(sprocDirectory, (returnedLinks) ->
  sprocLinks = returnedLinks
  console.log(sprocLinks)
  loadServer()
)


