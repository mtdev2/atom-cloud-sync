StorageClient = require('../lib/storage-client')
{Directory, File} = require 'pathwatcher'
path = require 'path'

describe 'StorageClient', ->

  fixturePath = () ->
    root = atom.project.getRootDirectory()
    return root.getRealPathSync()

  it 'creates a client', ->
    creds =
      provider: 'rackspace'
      username: 'bigcloud'
      apiKey: 'secretovaltine'
      region: 'SAT'

    mydata = []
    fulldata = null

    client =
      upload: () ->
        uploader =
          on: (stuff...) ->
            console.log("on")
            console.log(stuff)
          end: (stuff...) ->
            console.log("end")
            console.log(stuff)
          once: (stuff...) ->
            console.log("once")
            console.log(stuff)
          emit: (stuff...) ->
            console.log("emit")
            console.log(stuff)
          write: (stuff...) ->
            console.log(stuff)

    storageClient = new StorageClient(creds)

    storageClient.client = client

    fixtureDir =

    root = fixturePath()

    fileToUpload = path.join(root, "storage-client", "cats")

    storageClient.uploadFile(fileToUpload, "container", "object")


    waitsFor -> fulldata?

    runs -> expect(fulldata).toBe("test")
