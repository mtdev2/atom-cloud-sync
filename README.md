# Cloud Sync

**Like a 90s website, this is under construction.**

:construction_worker::construction_worker::construction_worker::construction_worker::construction_worker:

Sync Files to Cloud Storage from Atom

Uses pkgcloud to upload to files to a storage provider (Rackspace CloudFiles,
S3, etc.)


## Development

Use the atom [contributing guidelines](https://atom.io/docs/latest/contributing).
Quick summary:

```
$ apm develop cloud-sync
Cloning https://github.com/rackerlabs/atom-cloud-sync ✓
Installing modules ✓
/Users/mrdev/.atom/dev/packages/cloud-sync -> /Users/mrdev/github/cloud-sync
$ cd ~/github/cloud-sync/
```

You'll probably want to set your remotes up appropriately, as apm defaults to
setting the origin to the base repository as it won't know about your fork.

```
git remote add myfork git@github.com:<username>/cloud-sync.git
```

### Workflow

After pulling upstream changes, make sure to run `apm update`.

To start hacking, make sure to run `atom --dev` from the package directory.
Cut a branch while you're working then either submit a Pull Request when done
or when you want some feedback!
