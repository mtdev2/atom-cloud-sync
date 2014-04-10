# Methods for working with Files, Directories, and paths.

path = require 'path'
{File, Directory} = require 'pathwatcher'

# Internal: Recursive helper method for "nearestParent". Does the bulk of the
# work, but assumes that its initial parameter is a Directory.
#
nearestParentFrom = (directory, filename, callback) ->
  directory.getEntries (err, list) ->
    if err
      callback(err, null, null)
      return

    for entry in list
      if entry instanceof File and entry.getBaseName() is filename
        callback(err, directory, entry)
        return

    # TODO this won't work on non-*nix platforms! So, basically, Windows.
    real = directory.getRealPathSync()
    if real is '/'
      callback(null, null, null)
    else
      parent = new Directory(path.join directory.getPath(), '..')
      nearestParentFrom parent, filename, callback


module.exports =

  # Public: Discover the nearest parent directory that contains a file with
  # an expected filename while walking up the directory tree.
  #
  # beginning - File or Directory that marks a starting point.
  # filename  - Filename to search for.
  # callback  - Invoked with an error if any occur, the Directory in which
  #             `filename` was discovered, and a File wrapping the file. If
  #             no such file is discovered, `null` will be yielded instead.
  #
  nearestParent: (beginning, filename, callback) ->
    if beginning instanceof Directory
      nearestParentFrom beginning, filename, callback
    else
      dir = new Directory(path.dirname beginning.getPath())
