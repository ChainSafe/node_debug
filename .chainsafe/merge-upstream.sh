#!/bin/bash

# Configurations
UPSTREAM_REPO="https://github.com/nodejs/node.git"
BRANCH_PATTERN="v[0-9][0-9].x$"
MAIN_BRANCH="main"

# # Add upstream repo
git remote add upstream "$UPSTREAM_REPO" 2> /dev/null || true

# # Fetch all branches and tags from upstream
git fetch --all --tags

# # Rebase main branch with upstream
git checkout "$MAIN_BRANCH"
git reset --hard upstream/"$MAIN_BRANCH"
rm -rf .github
mkdir -p .github/scripts
git checkout origin/chainsafe .chainsafe .chainsafe/workflows
mv .chainsafe/workflows .github/workflows
mv .chainsafe/merge-upstream.sh .github/scripts/merge-upstream.sh
rm README.md
mv .chainsafe/README.md README.md
rm -rf .chainsafe
git add -A
git add -f .github
git commit -m "add chainsafe workflows and scripts"
git push origin "$MAIN_BRANCH" --force

# Merge branches matching the pattern
for branch in $(git branch -r | grep -E "upstream/$BRANCH_PATTERN"); do
    local_branch=$(echo $branch | sed 's/upstream\///')
    git checkout -b "$local_branch" 2>/dev/null || git checkout "$local_branch"
    git reset --hard "$branch"
    # remove .github folder so no scripts run
    rm -rf .github
    git add -f .github
    git commit -m "remove workflows and scripts"
    git push origin "$local_branch" --force
done

# Merge tags
git push origin --tags
