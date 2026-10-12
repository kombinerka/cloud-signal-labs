#!/usr/bin/env bash
# Remove a leaked file from the whole Git history, AFTER the secret has been revoked and replaced.
# Rewriting history doesn't reach clones and forks other people already have, so rotation is step one, always.
# Needs git-filter-repo (pip install git-filter-repo). Works on a fresh mirror clone, as the tool recommends.
# Usage: ./remove-from-history.sh https://github.com/my-org/my-app.git config/secrets.env
set -euo pipefail
repo="${1:?repo URL}"; file="${2:?path of the leaked file}"
work=$(mktemp -d)
git clone --mirror "$repo" "$work/repo.git"
cd "$work/repo.git"
git filter-repo --invert-paths --path "$file"
# To replace a secret string everywhere instead of deleting a file:
#   printf '%s\n' 'the-leaked-value==>REMOVED' > ../replacements.txt
#   git filter-repo --replace-text ../replacements.txt
echo "History rewritten in $work/repo.git. Check it, then force-push all branches and tags:"
echo "  cd $work/repo.git && git remote add origin $repo && git push --force --mirror origin"
echo "Then: ask collaborators to re-clone, and ask your Git host to purge cached views (GitHub: contact support for"
echo "pull request references and cached commits)."
