SyncDescription = require '../lib/sync-description'
{Directory} = require 'pathwatcher'
path = require 'path'

describe 'SyncDescription', ->

  fixtureRoot = path.join 'spec', 'fixtures', 'spec-description'

  fixtureDir = () -> new Directory(fixtureRoot)

  it 'finds all .cloud-sync.json files in the project', ->
    dirs = []
    SyncDescription.findAllIn fixtureDir(), (err, desc) =>
      dirs.push(desc.directory.getBaseName())
    expect(dirs).toEqual(['foo', 'baz'])
