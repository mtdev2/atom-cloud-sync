SyncDescription = require '../lib/sync-description'
{Directory, File} = require 'pathwatcher'
path = require 'path'

describe 'SyncDescription', ->

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

  it 'finds all .cloud-sync.json files in the project', ->
    dirs = []

    SyncDescription.findAllIn fixtureDir(), (err, desc) =>
      dirs.push(desc.directory.getBaseName())

      if dirs.length is 2
        expect(dirs).toContain('bar')
        expect(dirs).toContain('foo')
      expect(dirs.length > 2).not.toBe(true)

  it 'parses configuration data from .cloud-sync.json', ->
    withDescription ['bar', '.cloud-sync.json'], (sd) ->
      expect(sd.container).toBe('magic')
      expect(sd.psuedoDirectory).toBe('somedir/')
