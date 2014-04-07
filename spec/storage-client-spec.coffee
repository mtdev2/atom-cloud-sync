StorageClient = require('../lib/storage-client')
{Directory, File} = require 'pathwatcher'
path = require 'path'

Stream = require 'stream'

describe 'StorageClient', ->

  fixturePath = () ->
    root = atom.project.getRootDirectory()
    return root.getRealPathSync()

  it 'uploads a file using pkgcloud\'s built-in upload', ->

    # Just using a valid provider for now
    # TODO: Mock the creation of the client
    creds =
      provider: 'rackspace'
      username: 'bigcloud'
      apiKey: 'secretovaltine'
      region: 'SAT'

    storageClient = new StorageClient(creds)

    # We'll mock the internal client of the storageClient
    # To handle the data upload

    bufferedData = []
    fulldata = null

    client =
      upload: () ->

        # Set up the object that handles piped in data
        stream = new Stream.Writable()
        stream.write = (data, stuff...) ->
          bufferedData.push(data)
          return true

        stream.end = (stuff...) ->
          fulldata = bufferedData.join("").trim()

        return stream

    storageClient.client = client

    fileToUpload = path.join(fixturePath(), "storage-client", "cats")

    storageClient.uploadFile(fileToUpload, "container", "object")

    waitsFor -> fulldata?

    runs -> expect(fulldata).toBe("MEOW")
