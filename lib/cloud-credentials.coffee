{Directory, File} = require 'pathwatcher'
path = require 'path'
pathHelpers = require './path-helpers'

FILENAME = '.cloud-credentials.json'

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
    pathHelpers.nearestParent directory, FILENAME, (err, dir, file)->
      CloudCredentials.createFrom file, callback
