CloudCredentials = require '../lib/cloud-credentials'
{File} = require 'pathwatcher'
path = require 'path'

describe 'CloudCredentials', ->

  it 'loads from a .cloud-credentials.json file', ->
    root = atom.project.getRootDirectory().getRealPathSync()
    f = new File(path.join root, '.cloud-credentials.json')
    credentials = null

    f.read(false).then (contents) ->
      console.log contents
      settings = JSON.parse(contents)
      console.log CloudCredentials
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
