StorageClient = require './storage-client'
syncdesc = require './sync-description'
{SyncDescription, NoDescriptionError, FILENAME: DESCFILE} = syncdesc
{FILENAME: CREDFILE} = require './cloud-credentials'
{File, Directory} = require 'pathwatcher'

syncview = require './sync-view'
path = require 'path'

module.exports =

  storageClient: null

  activate: (state) ->

    # TODO: Extract into a config
    creds =
      provider: 'rackspace'
      username: process.env.OS_USERNAME
      apiKey: process.env.OS_PASSWORD
      region: process.env.OS_REGION_NAME

    @storageClient = new StorageClient(creds)

    getSelectedView = ->
      selectedView = atom.workspaceView.find('.tree-view .selected')?.view()

    # Uploads the selected directory or file
    uploadSelection = ->
      view = getSelectedView()

      if(view.file?)
        uploadFile(view)
      else if(view.directory?)
        uploadDirectory(view)
      else
        console.log("What kind of view are you?")

    uploadDirectory = (view) ->
      console.error("Directory upload not implemented")

    uploadFile = (view) =>
      itemPath = view.getPath()

      if itemPath?
        fileName = view.fileName.text()

        console.log("Synergizing #{ itemPath } with the cloud")

        @storageClient.uploadFile(itemPath, "cloudsync", fileName)

    atom.workspaceView.command 'cloud-sync:sync', uploadSelection

    atom.on 'cloud-sync:sync-file', (event) ->
      SyncDescription.uploadFile event.file, (err) -> throw err if err?

    atom.workspaceView.command 'cloud-sync:sync-all', ->
      SyncDescription.findAll (err, description) ->
        throw err if err?
        description.upload()

    syncview.registerOpenerIn atom.workspace
    atom.workspaceView.command 'cloud-sync:sync-dialog', ->
      atom.workspace.open syncview.shareUriFor getSelectedView().getPath()

    atom.workspace.eachEditor (editor) ->
      buffer = editor.getBuffer()
      file = buffer.file

      if file.getBaseName() isnt CREDFILE and file.getBaseName() isnt DESCFILE
        buffer.on 'saved', ->
          SyncDescription.uploadFile file, (err) ->
            throw err if err? and not err instanceof NoDescriptionError
