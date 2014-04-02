{WorkspaceView} = require 'atom'
CloudSync = require '../lib/cloud-sync'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "CloudSync", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('cloud-sync')

  describe "when the cloud-sync:sync event is triggered", ->
    it "attempts to sync the selected file", ->

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'cloud-sync:sync'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.cloud-sync')).toExist()
        atom.workspaceView.trigger 'cloud-sync:toggle'
        expect(atom.workspaceView.find('.cloud-sync')).not.toExist()
