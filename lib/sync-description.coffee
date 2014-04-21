path = require 'path'
{File, Directory} = require 'pathwatcher'
{CloudCredentials, FILENAME: CREDFILE} = require './cloud-credentials'

pathHelpers = require './path-helpers'

FILENAME = '.cloud-sync.json'

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
    @psuedoDirectory = settings.directory or '/'

    unless @container?
      throw new Error("#{@configPath()} is missing a required 'container' key!")

  # Public: Returns the full path of the ".cloud-sync.json" file that created
  # this instance.
  #
  configPath: ->
    path.join @directory.getRealPathSync(), FILENAME

  # Public: Scan the filesystem for the CloudCredentials relevant to this
  # directory and yield them to the provided callback.
  #
  # callback - Invoked with any errors that are recognized, or with the
  #            CloudCredentials instance relevant to this directory.
  #
  withCredentials: (callback) ->
    CloudCredentials.withNearest @directory, callback

  # Public: Iterate over the "pushable" contents of this directory; that is,
  # all files contained recursively within the root directory of this
  # SyncDescription or any child directory, except for the cloud-sync dotfile.
  #
  # callback - Invoked with any errors that are encountered, or with the full
  #            path to each file.
  #
  withEachPath: (callback) ->
    helper = (root) ->
      root.getEntries (err, entries) ->
        if err?
          callback(err)
          return

        for entry in entries
          if entry instanceof File
            baseName = entry.getBaseName()
            if baseName isnt FILENAME and baseName isnt CREDFILE
              callback(null, entry.getRealPathSync())
          if entry instanceof Directory
            helper(entry)

    helper(@directory)

  # Public: Locate the nearest ".cloud-sync.json" file encountered walking up
  # the directory tree. Parse the first one found into a SyncDescription.
  #
  # directory - The Directory of the starting point for the scan.
  # callback  - Invoked with any errors that are encountered, with a
  #             SyncDescription instance if one is discovered, or with "null"
  #             if none are.
  @withNearest: (directory, callback) ->
    pathHelpers.nearestParent directory, FILENAME, (err, dir, file) =>
      if err?
        callback(err, null, null)
        return

      if dir? and file?
        @createFrom file, dir, callback
      else
        callback(null, null, null)

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
        else if entry.getBaseName() is FILENAME
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

module.exports =

  SyncDescription: SyncDescription

  FILENAME: FILENAME
