CloudCredentials = require '../lib/cloud-credentials'
{File, Directory} = require 'pathwatcher'
path = require 'path'

describe 'CloudCredentials', ->

  it 'loads from a .cloud-credentials.json file', ->
    root = atom.project.getRootDirectory().getRealPathSync()
    f = new File(path.join root, '.cloud-credentials.json')
    credentials = null

    f.read(false).then (contents) ->
      settings = JSON.parse(contents)
      credentials = new CloudCredentials(settings)

    waitsFor -> credentials?

    runs ->
      expect(credentials.provider).toBe('rackspace')
      expect(credentials.username).toBe('defaultuser')
      expect(credentials.apiKey).toBe('yomama')
      expect(credentials.region).toBe('DFW')

  it 'creates itself from a File', ->
    root = atom.project.getRootDirectory().getRealPathSync()
    f = new File(path.join, '.cloud-credentials.json')

    CloudCredentials.createFrom f, (creds) ->
      expect(creds.username).toBe('defaultuser')

  it 'finds the nearest .cloud-credentials.json up the directory hierarchy', ->
    root = atom.project.getRootDirectory().getRealPathSync()
    d = new Directory(path.join root, 'sync-description', 'bar')
    credentials = null

    CloudCredentials.withNearest d, (err, creds) ->
      console.log err if err
      credentials = creds

    waitsFor -> credentials?

    runs ->
      expect(credentials.username).toBe('defaultuser')
