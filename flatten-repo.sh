#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
SRC="deevnet/builder"

if [[ ! -d .git ]]; then
  echo "ERROR: This does not look like a git repo (no .git found). Run from repo root."
  exit 1
fi

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: Source path '$SRC' not found. Are you in the repo root?"
  exit 1
fi

echo "Repo root: $REPO_ROOT"
echo "Migrating collection root from '$SRC' to repo root using git mv..."
echo

# Helper: git mv if source exists
gmv() {
  local from="$1"
  local to="$2"
  if [[ -e "$from" ]]; then
    # If target exists, fail fast (we don't want accidental merges)
    if [[ -e "$to" ]]; then
      echo "ERROR: Target already exists: $to  (won't overwrite)."
      exit 1
    fi
    git mv "$from" "$to"
    echo "Moved: $from -> $to"
  else
    echo "Skip (missing): $from"
  fi
}

# 1) Move primary collection files/dirs to repo root
gmv "$SRC/galaxy.yml" "./galaxy.yml"
gmv "$SRC/meta"       "./meta"
gmv "$SRC/playbooks"  "./playbooks"
gmv "$SRC/plugins"    "./plugins"
gmv "$SRC/roles"      "./roles"

# 2) Handle nested README without clobbering root README.md
if [[ -e "$SRC/README.md" ]]; then
  if [[ -e "./README.md" ]]; then
    gmv "$SRC/README.md" "./COLLECTION_README.md"
    echo "NOTE: Root README.md already exists, so nested README moved to COLLECTION_README.md"
  else
    gmv "$SRC/README.md" "./README.md"
  fi
fi

# 3) Clean up now-empty dirs (git rm only removes tracked files; dirs disappear automatically)
# But we can remove empty directories from the working tree (non-fatal)
rmdir "$SRC" 2>/dev/null || true
rmdir "deevnet" 2>/dev/null || true

echo
echo "Done moving. Current status:"
git status -sb

echo
echo "Next steps:"
echo "  1) Review changes: git diff --stat"
echo "  2) Build the collection from repo root:"
echo "       ansible-galaxy collection build --force"
echo "  3) Install the built tarball:"
echo "       ansible-galaxy collection install deevnet-builder-*.tar.gz --force"
echo "  4) Run your playbook:"
echo "       ansible-playbook -i inventory playbooks/site.yml"
