module.exports =
  activate: (state) ->
    atom.workspaceView.command 'cloud-sync:sync', ->
      if itemPath = getActiveSidebarPath()
        console.log("Synergizing #{ itemPath } with the cloud")

getActiveSidebarPath = ->
  path = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
