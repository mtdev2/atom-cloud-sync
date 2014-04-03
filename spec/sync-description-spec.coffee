SyncDescription = require '../lib/sync-description'
{Directory} = require 'pathwatcher'
path = require 'path'

describe 'SyncDescription', ->

  fixtureDir = () ->
    root = atom.project.getRootDirectory()
    new Directory(path.join root.getRealPathSync(), 'sync-description')

  it 'finds all .cloud-sync.json files in the project', ->
    dirs = []
    SyncDescription.findAllIn fixtureDir(), (err, desc) =>
      dirs.push(desc.directory.getBaseName())

      if dirs.length is 2
        expect(dirs).toContain('bar')
        expect(dirs).toContain('foo')
