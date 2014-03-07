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

    getSelectedView = =>
      selected_view = atom.workspaceView.find('.tree-view .selected')?.view()

    logFile = =>
      if itemPath = getSelectedView().getPath()
        console.log("Synergizing #{ itemPath } with the cloud")

    uploadFile = =>
      view = getSelectedView()
      itemPath = view.getPath()

      if itemPath?
        fileName = view.fileName.text()

        console.log("CyberSynergizing #{ itemPath } with the cloud")
        
        @storage.uploadFile(itemPath, "cloudsync", fileName)

    atom.workspaceView.command 'cloud-sync:sync', uploadFile
