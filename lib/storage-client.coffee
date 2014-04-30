pkgcloud = require 'pkgcloud'
fs = require 'fs'

# Just placing this here to have a dummy callback.
#
genericCallback = (err, result) ->
  if err?
    console.error(err)
  else
    console.log(result)

module.exports =
class StorageClient

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
  #  storage = new StorageClient(creds)
  #
  constructor: (creds) ->
    @client = pkgcloud.storage.createClient(creds)

  # Uploads filePath to objectName in container containerName. Creates the
  # container if necessary.
  #
  uploadFile: (filePath, containerName, objectName, cdn) ->
    console.log("Uploading #{filePath} into #{containerName} as #{objectName}")

    @client.createContainer containerName, (err, container) =>
      throw err if err?

      @client.setCdnEnabled containerName, cdn, (err) =>
        throw err if err?

        file = fs.createReadStream(filePath)

        layout =
          container: containerName
          remote: objectName

        file.pipe(@client.upload(layout, genericCallback))

  # Upload all the files within the directory into the container, starting
  # them off with objectPath
  uploadDirectory: (container, directory, objectPath) ->
    console.error("Not implemented yet")
