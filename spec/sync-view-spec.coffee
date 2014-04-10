sv = require '../lib/sync-view'
{SyncDescription} = require '../lib/sync-description'
path = require 'path'
{Directory, File} = require 'pathwatcher'

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

  describe 'finishInitialization', ->

    it 'disables the Apply button until data is loaded', ->
      view = syncViewIn 'parent', 'child'
      expect(view.ready).toBe(false)
      expect(view.applyButton.prop 'disabled').toBe(true)

    it 'populates editors with existing data', ->
      view = syncViewIn 'parent', 'child'
      waitsFor -> view.ready
      runs ->
        expect(view.containerName.getEditor().getText()).toBe('derpderp')
        expect(view.directoryName.getEditor().getText()).toBe('snorf')

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

    it 'uses a new .cloud-sync.json file if none exists', ->
      view = syncViewIn 'nodesc'

      waitsFor -> view.ready

      runs ->
        rp = view.getSyncFile().getRealPathSync()
        expect(rp).toBe(fullPathFor 'nodesc', '.cloud-sync.json')

    it 'finds a .cloud-sync.json file in a parent directory', ->
      view = syncViewIn 'parent', 'child'

      waitsFor -> view.ready

      runs ->
        rp = view.getSyncFile().getRealPathSync()
        expect(rp).toBe(fullPathFor 'parent', '.cloud-sync.json')

  describe 'apply', ->

    it 'writes a .cloud-sync.json file', ->
      view = syncViewIn 'nodesc'
      waitsFor -> view.ready
      runs ->
        view.containerName.getEditor().setText 'superawesome'
        view.directoryName.getEditor().setText 'blerp'

        view.apply()

        dir = new Directory(fullPathFor 'nodesc')
        sf = new File(fullPathFor 'nodesc', '.cloud-sync.json')
        expect(sf.exists()).toBe(true)

        sd = null
        SyncDescription.createFrom sf, dir, (err, desc) ->
          console.log err if err
          sd = desc
        waitsFor -> sd?

        runs ->
          expect(sd.container).toBe('superawesome')
          expect(sd.psuedoDirectory).toBe('blerp')
