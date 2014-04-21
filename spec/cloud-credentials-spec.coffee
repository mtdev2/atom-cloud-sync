{CloudCredentials, FILENAME} = require '../lib/cloud-credentials'
{File, Directory} = require 'pathwatcher'
path = require 'path'

describe 'CloudCredentials', ->

  it "loads from a #{FILENAME} file", ->
    root = atom.project.getRootDirectory().getRealPathSync()
    f = new File(path.join root, FILENAME)
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
    f = new File(path.join, FILENAME)

    CloudCredentials.createFrom f, (creds) ->
      expect(creds.username).toBe('defaultuser')

  it "finds the nearest #{FILENAME} up the directory hierarchy", ->
    root = atom.project.getRootDirectory().getRealPathSync()
    d = new Directory(path.join root, 'sync-description', 'bar')
    credentials = null

    CloudCredentials.withNearest d, (err, creds) ->
      console.log err if err
      credentials = creds

    waitsFor -> credentials?

    runs ->
      expect(credentials.username).toBe('defaultuser')
