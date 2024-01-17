# ChainSafe Node.js Debug Builds

This repo is built to follow the upstream nodejs/node repo.  The goal of this is to build and host Debug builds of node in the releases so that they can be pulled and installed by CI in Lodestar.  Our fork of `actions/setup-node` points at this repo for the hosted binaries.

Do not make any changes to code in this repo as it is designed to reset --hard to upstream so it is identical.  There is only one disparate branch and that is `chainsafe` which is used to hold assets that get copied in to keep the repo in sync.  There are only two workflows that are maintained here and the rest of the workflows from upstream are deleted to keep down CI costs and noise.  All validation is done by the upstream repo.

### Workflows

The two workflows are:

- `sync-fork`: Cron job that runs every 6 hours to sync the fork to upstream. Runs the `merge-upstream.sh` script.  Can manually trigger this workflow from the Github UI
- `publish-release`: Triggered by new tag pushes and builds the release for each new tag. Can also be triggered manually from the Github UI

### Scripts

The only script in the repo for now is `merge-upstream.sh`. This script fetches all changes and tags from upstream and applies any new commits to main via `git reset --hard` so that all changes in this repo are overwritten and it is identical to upstream.  Then the script removes the `.github` folder and copies over the assets from the `chainsafe` branch, in the `.chainsafe` folder to the main branch `.github` folder and commits the changes.  The files that are copied are the two workflows mentioned above, the `merge-upstream.sh` script and this README.md file.

The single commit with the chainsafe assets is always the last commit on `main` and is reset to upstream (and then re-copied over as the last commit) on every run of the script.

The script also keeps the version branches synced with upstream.  It syncs all branches with the `v[0-9][0-9].x$` branch pattern (matches v16.x, v18.x, v20.x, etc) from upstream to the fork to make sure that all tags that get built have the correct commits present (just in case they are not on main for some reason).

All tags are also sync'd.
