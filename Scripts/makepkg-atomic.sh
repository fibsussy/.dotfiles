#!/usr/bin/env bash
set -euo pipefail

# Atomic makepkg wrapper: copies git-tracked files to a temp dir,
# runs makepkg there, and always cleans up on exit.

# Must be run from within a git repo
if ! git rev-parse --show-toplevel &>/dev/null; then
    echo "error: not inside a git repository" >&2
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
TMPDIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

# Copy all git-tracked + untracked-but-not-ignored files into the temp dir
# git ls-files -co --exclude-standard: cached (tracked) + other (untracked, non-ignored)
git -C "$REPO_ROOT" ls-files -co --exclude-standard | while IFS= read -r file; do
    dest="$TMPDIR/$file"
    mkdir -p "$(dirname "$dest")"
    cp "$REPO_ROOT/$file" "$dest"
done

cd "$TMPDIR"
makepkg "$@"
