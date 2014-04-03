module.exports =

# Public: Manage credentials and other Secret Information.
#
class CloudCredentials

  # Internal: capture pkgcloud credentials.
  #
  constructor: ({@provider, @username, @apiKey, @region}) ->
