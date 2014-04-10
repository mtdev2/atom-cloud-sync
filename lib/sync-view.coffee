{$$, ScrollView, EditorView} = require 'atom'
{Directory, File} = require 'pathwatcher'
path = require 'path'

{SyncDescription, FILENAME} = require './sync-description'

class SyncView extends ScrollView

  @content: ->
    @div class: 'syncview padded pane-item tool-panel', =>
      @h1 =>
        @text 'Synchronize This Directory With The '
        @i class: 'icon icon-cloud-upload'
      @div class: 'panel bordered', =>
        @div class: 'panel-heading', 'Where Should It Go?'
        @div class: 'panel-body padded', =>
          @div class: 'block', outlet: 'containerInput', =>
            @div style: 'display: none', outlet: 'containerErr', =>
              @i class: 'icon icon-alert'
              @span 'You must specify a non-empty container name.'
            @label class: 'inline-block', 'Container Name'
            @subview 'containerName', new EditorView(mini: true)
          @div class: 'block', =>
            @label class: 'inline-block', 'Directory'
            @subview 'directoryName', new EditorView(mini: true)
          @div class: 'block', =>
            @button({
              class: 'btn btn-lg btn-primary',
              disabled: true,
              outlet: 'applyButton',
              click: 'apply'
            }, 'Apply')

  initialize: (@uri) ->
    @ready = false

    [_, dirPath] = @uri.match /^cloud-sync-config:\/(.*)/
    @directory = new Directory dirPath
    SyncDescription.withNearest @directory, (err, instance) =>
      throw err if err
      @syncDescription = instance
      @ready = true

    @containerName.getEditor().on 'contents-modified', => @checkValidity()

  getUri: -> @uri

  getTitle: -> "Synchronizing #{path.basename @uri}"

  checkValidity: ->
    errs = []

    name = @containerName.getText()
    if name.length is 0
      errs.push 'You must provide a nonempty container name.'

    if name.length > 256
      errs.push 'Container names must be less than 256 characters.'

    if /[\/]/.test name
      errs.push 'Container names can\'t contain the "/" character.'

    @containerErr.empty()

    if errs.length is 0
      @containerInput.removeClass 'text-error'
      @containerErr.css 'display', 'none'
      @applyButton.prop 'disabled', false
    else
      @containerInput.addClass 'text-error'
      @containerErr.css 'display', 'block'
      @applyButton.prop 'disabled', true

    for err in errs
      @containerErr.append $$ ->
        @i class: 'icon icon-warning'
        @span err

  getSyncFile: ->
    unless @ready?
      throw new Error('SyncView not ready')

    if @syncDescription?
      new File(@syncDescription.configPath())
    else
      new File(path.join @directory.getPath(), FILENAME)

  apply: ->
    @getSyncFile().write JSON.stringify
      container: @containerName.getText()
      directory: @directoryName.getText()

module.exports =

  SyncView: SyncView

  shareUriFor: (path) -> 'cloud-sync-config:/' + path

  registerOpenerIn: (workspace) ->
    workspace.registerOpener (filePath) ->
      new SyncView(filePath) if /^cloud-sync-config:\/\//.test filePath
