StorageClient = require('./storage-client')

syncview = require './sync-view'

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

    syncview.registerOpenerIn atom.workspace
    atom.workspaceView.command 'cloud-sync:sync-dialog', ->
      atom.workspace.open syncview.shareUriFor getSelectedView().getPath()
