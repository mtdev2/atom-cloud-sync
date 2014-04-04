sv = require '../lib/sync-view'

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
