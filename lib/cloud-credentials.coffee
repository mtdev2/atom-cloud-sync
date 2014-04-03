{Directory, File} = require 'pathwatcher'
path = require 'path'

module.exports =

# Public: Manage credentials and other Secret Information.
#
class CloudCredentials

  # Internal: Capture pkgcloud credentials.
  #
  constructor: ({@provider, @username, @apiKey, @region}) ->

  # Public: Create a CloudCredentials object from a ".cloud-credentials.json"
  # file.
  #
  # file     - A File containing pkgcloud credentials in JSON form.
  # callback - Will be invoked with any errors and the constructed instance.
  #
  @createFrom: (file, callback) ->
    promise = file.read(true)
    promise.then (content) ->
      settings = JSON.parse(content)
      instance = new CloudCredentials(settings)
      callback(null, instance)
    promise.catch (err) ->
      callback(err, null)

  # Public: Search the directory hierarchy for the nearest
  # ".cloud-credentials.json".
  #
  # directory - The current Directory that's the search context.
  # callback  - Will be invoked with any errors and the constructed instance.
  #
  @withNearest: (directory, callback) ->
    directory.getEntries (err, list) =>
      if err
        callback(err, null)
        return

      found = false
      for entry in list
        if entry instanceof File and entry.getBaseName() is '.cloud-credentials.json'
          found = true
          CloudCredentials.createFrom entry, (err, instance) ->
            callback(err, instance)

      unless found
        real = directory.getRealPathSync()
        parent = new Directory(path.join directory.getPath(), '..')

        # TODO this won't work on non-*nix platforms! So, basically, Windows.
        if real is '/'
          callback(null, null)
        else
          @withNearest parent, callback
