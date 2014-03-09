pkgcloud = require('pkgcloud')
fs = require('fs')

# _ = require 'underscore-plus'

module.exports =

class Storage

  # Cloud Storage
  #
  # Accepts a pkgcloud credential object
  #
  # Example:
  #  creds =
  #    provider: 'rackspace'
  #    username: process.env.OS_USERNAME
  #    apiKey: process.env.OS_PASSWORD
  #    region: process.env.OS_REGION_NAME
  #
  #  storage = new Storage(creds)
  #
  constructor: (creds) ->
    @client = pkgcloud.storage.createClient(creds)

  # Uploads filePath to objectName in container containerName
  uploadFile: (filePath, containerName, objectName) ->

    console.log("Uploading")

    file = fs.createReadStream(filePath)

    layout =
      container: containerName
      remote: objectName

    file.pipe(@client.upload(layout, @genericCallback))

  # Upload all the files within the directory into the container, starting
  # them off with objectPath
  uploadDirectory: (container, directory, objectPath) ->
    console.error("Not implemented yet")


# Just placing this here to have a dummy callback
genericCallback: (err, result) ->
  if err?
    console.error(err)
    return
  console.log(result)
