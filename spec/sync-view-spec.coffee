sv = require '../lib/sync-view'
path = require 'path'

describe 'shareUriFor', ->

  it 'forms proper cloud-sync-config uris', ->
    actual = sv.shareUriFor '/some/absolute/path'
    expected = 'cloud-sync-config://some/absolute/path'
    expect(actual).toBe(expected)

describe 'registerOpenerIn', ->

  it 'registers a cloud-sync-config opener', ->
    gotit = false

    receiver =
      registerOpener: (callback) -> gotit = true

    sv.registerOpenerIn receiver
    expect(gotit).toBe(true)

describe 'SyncView', ->

  [base] = []

  fullPathFor = (relativePath...) ->
    path.join base, 'sync-view', relativePath...

  syncViewIn = (relativePath...) ->
    uri = sv.shareUriFor fullPathFor relativePath...
    new sv.SyncView(uri)

  beforeEach ->
    base = atom.project.getRootDirectory().getRealPathSync()

  describe 'checkValidity', ->

    [view] = []

    beforeEach -> view = syncViewIn 'nodesc'

    it 'disallows empty container names', ->
      view.containerName.getEditor().setText ''
      view.checkValidity()

      expect(view.containerInput.hasClass 'text-error').toBe(true)
      expect(view.containerErr.css 'display').toBe('block')
      messages = view.containerErr.find('span')
      expect(messages.length).toBe(1)

    it 'disallows the / character', ->
      view.containerName.getEditor().setText "I'm rgbkrk / and I'm here to say
        / I like breaking stuff / every day"
      view.checkValidity()

      expect(view.containerInput.hasClass 'text-error').toBe(true)
      expect(view.containerErr.css 'display').toBe('block')
      messages = view.containerErr.find('span')
      expect(messages.length).toBe(1)

    it 'accepts anything else', ->
      view.containerName.getEditor().setText 'valid'
      view.checkValidity()

      expect(view.containerInput.hasClass 'text-error').toBe(false)
      expect(view.containerErr.css 'display').toBe('none')
      messages = view.containerErr.find('span')
      expect(messages.length).toBe(0)

  describe 'getSyncFile', ->

    it 'finds the .cloud-sync.json file matching the URI', ->
      view = syncViewIn 'nodesc'
      rp = view.getSyncFile().getRealPathSync()
      expect(rp).toBe(fullPathFor 'nodesc', '.cloud-sync.json')
