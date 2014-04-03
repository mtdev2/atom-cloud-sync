StorageClient = require('../lib/storage-client')
{Directory, File} = require 'pathwatcher'
path = require 'path'

describe 'StorageClient', ->

  fixtureDir = () ->
    root = atom.project.getRootDirectory()

    new Directory(path.join root.getRealPathSync(), 'sync-description')

  withDescription = (subpath, callback) ->
    root = fixtureDir().getRealPathSync()

    dirname = path.join root, subpath[..-2]...
    d = new Directory dirname

    fname = path.join root, subpath...
    f = new File fname


  it 'creates a client', ->
    creds =
      provider: 'rackspace'
      username: 'user'
      apiKey: 'secretovaltine'
      region: 'IAD'

    storageClient = new StorageClient(creds)
