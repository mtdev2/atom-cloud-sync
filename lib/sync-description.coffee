path = require 'path'
{Directory} = require 'pathwatcher'

module.exports =

# Public: Model corresponding to a dotfile that describes where and how a
# directory should be synchronized with a cloud storage container.
#
class SyncDescription

  # Internal: Create a new SyncDescription from the contents of a
  # ".cloud-sync.json" file.
  #
  # directory - The Directory to be synchronized.
  # settings  - Customize the synchronization behavior.
  #             container - Required. The container that this directory should
  #                         be mapped to within cloud storage.
  #             directory - Optional. Psuedodirectory within the target
  #                         container that files should be placed within.
  #
  # Raises InvalidSyncConfiguration if required settings are missing.
  #
  constructor: (@directory, settings) ->
    @container = settings.container
    @psuedoDirectory = settings.directory

    unless @container?
      throw
        name: 'InvalidSyncConfiguration'
        description: "#{@configPath()} is missing a required 'container' key!"

  # Public: Returns the full path of the ".cloud-sync.json" file that created
  # this instance.
  configPath: ->
    path.join @directory.getRealPathSync(), '.cloud-sync.json'

  # Public: Scan the current project's filesystem for directories containing
  # ".cloud-sync.json" files. Parse each one into a SyncDescription and send it
  # to a callback.
  #
  # callback - Invoked with any errors that are encountered, and once for each
  #            SyncDescription instance that is discovered and instantiated.
  #
  @findAll: (callback) -> @findAllIn(atom.project.getRootDirectory(), callback)

  # Public: Scan the filesystem recursively underneath a given root directory
  # for directories containing a ".cloud-sync.json" file.
  #
  # root     - The root directory to begin the search.
  # callback - Invoked with any errors that are encountered, and once for each
  #            SyncDescription instance encountered.
  #
  @findAllIn: (root, callback) ->
    root.getEntries (err, list) =>
      return callback(err, null) if err

      for entry in list
        if entry instanceof Directory
          @findAllIn entry, callback
        else if entry.getBaseName() is '.cloud-sync.json'
          @createFrom entry, root, callback

  # Internal: Construct a new instance from the parsed contents of a
  # ".cloud-sync.json" file.
  #
  # source   - File containing the JSON description.
  # root     - The Directory that contains "source".
  # callback - Invoked with any errors that are encountered, or with the
  #            newly created SyncDescription.
  #
  @createFrom: (source, root, callback) ->
    promise = source.read(true)
    promise.then (content) ->
      settings = JSON.parse(content)
      instance = new SyncDescription(root, settings)
      callback(null, instance)
    promise.catch (err) -> callback(err, null)
