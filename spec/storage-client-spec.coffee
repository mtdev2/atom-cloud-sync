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

    sd = null
    SyncDescription.createFrom f, d, (err, instance) ->
      if err
        console.log err
        callback(null)
      sd = instance

    waitsFor -> sd?
    runs -> callback(sd)

  it
