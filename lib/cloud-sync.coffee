Storage = require('./storage-client')

module.exports =

  storage: null

  activate: (state) ->

    creds =
      provider: 'rackspace'
      username: process.env.OS_USERNAME
      apiKey: process.env.OS_PASSWORD
      region: process.env.OS_REGION_NAME

    @storage = new Storage(creds)

    getSelectedView = ->
      selectedView = atom.workspaceView.find('.tree-view .selected')?.view()

    upload = ->
      view = getSelectedView()

      if(view.file?)
        uploadFile(view)
      else if(view.directory?)
        uploadDirectory(view)
      else
        console.log("What kind of view are you?")

    uploadDirectory = (view) =>
      console.error("Directory upload not implemented")

    uploadFile = (view) =>

      itemPath = view.getPath()

      if itemPath?
        fileName = view.fileName.text()

        console.log("Synergizing #{ itemPath } with the cloud")

        @storage.uploadFile(itemPath, "cloudsync", fileName)

    atom.workspaceView.command 'cloud-sync:sync', upload
