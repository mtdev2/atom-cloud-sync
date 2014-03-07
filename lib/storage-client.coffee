pkgcloud = require('pkgcloud')
fs = require('fs')

# _ = require 'underscore-plus'

module.exports =

class Storage

  constructor: (creds) ->
    @client = pkgcloud.storage.createClient(creds)

  uploadFile: (filePath, containerName, objectName) ->

    console.log("Uploading")

    file = fs.createReadStream(filePath)

    layout =
      container: containerName
      remote: objectName

    file.pipe(@client.upload(layout, @genericCallback))

  uploadDirectory: (container, directory, objectPath) ->
    console.error("Not implemented yet")


# Just placing this here to have
genericCallback: (err, result) ->
  if err?
    console.error(err)
    return
  console.log(result)
