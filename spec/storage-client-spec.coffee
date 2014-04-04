StorageClient = require('../lib/storage-client')
{Directory, File} = require 'pathwatcher'
path = require 'path'

pkgcloud = require('pkgcloud')

Stream = require 'stream'

# A totally hokey storage client for pkgcloud
class FakeCloudClient

  constructor: (creds) ->
    @creds = creds

    @bufferedData = []
    @fulldata = null

    # Solely for later inspection/`expect`ation
    @uploadOptions = null
    @uploadCallback = null

  upload: (options, callback) ->
    # Clear out any old data
    @bufferedData = []
    @fulldata = null

    @uploadOptions = options
    console.log(options)
    @uploadCallback = callback

    # Set up the object that handles piped in data
    stream = new Stream.Writable()
    stream.write = (data, stuff...) =>
      @bufferedData.push(data)
      return true

    stream.end = (stuff...) =>
      @fulldata = @bufferedData.join("").trim()

    return stream

describe 'StorageClient', ->

  fixturePath = () ->
    root = atom.project.getRootDirectory()
    return root.getRealPathSync()

  it 'uploads a file using pkgcloud\'s built-in upload', ->

    # Just using a valid provider for now
    # TODO: Mock the creation of the client
    creds =
      provider: 'totallyfake'
      username: 'bigcloud'
      apiKey: 'secretovaltine'

    mockClient = null

    # Mock out the createClient so it creates a FakeCloudClient instead
    pkgcloud.storage.createClient = (options) ->
      expect(options).toBe(creds)
      mockClient = new FakeCloudClient(options)
      return mockClient

    storageClient = new StorageClient(creds)

    # We'll mock the internal client of the storageClient
    # To handle the data upload

    fileToUpload = path.join(fixturePath(), "storage-client", "cats")

    storageClient.uploadFile(fileToUpload, "container", "object")

    waitsFor -> mockClient.fulldata?

    runs -> expect(mockClient.fulldata).toBe("MEOW")
