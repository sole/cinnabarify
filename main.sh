#!/bin/bash

# if user has homebrew installed, install all dependencies
#if [ -x "$(command -v brew)" ]; then
#    brew install git hg git-cinnabar
#fi

# check for git, hg, git-cinnabar to be installed
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v hg)" ]; then
  echo 'Error: mercurial is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v pip)" ]; then
  echo 'Error: pip is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v git-cinnabar)" ]; then
  if [ -x "$(command -v brew)" ]; then
    brew install git hg git-cinnabar
  else
    echo 'Error: git cinnabar is not installed, and brew is not available (to install dependencies)' >&2
    exit 1
  fi
fi

# If target directory isn't specified, exit.
# Note: $# is the number of arguments.
if [ "$#" -eq 0 ]; then
	echo "👉 ERROR: Please specify the target directory (i.e. where you want to get a Firefox tree that uses git-cinnabar)"
	exit;
fi

# All good, let's do this

DESTINATION=$1
	
echo "~~~ Cinnabarifying $DESTINATION... ~~~"

if [ -f "$DESTINATION" ]; then
	echo "$DESTINATION already exists, please specify another directory"
	exit
fi

git -c cinnabar.clone=https://github.com/glandium/gecko clone hg::https://hg.mozilla.org/mozilla-unified "$DESTINATION" && cd "$DESTINATION"

# The docs say this makes git-cinnabar happier
git config fetch.prune true

# If watchman is installed, this makes git status and friends faster
if [ -x "$(command -v watchman)" ]; then
  mv .git/hooks/fsmonitor-watchman.sample .git/hooks/query-watchman
  git config core.fsmonitor .git/hooks/query-watchman
fi

# Setup a remote for the try server:
git remote add try hg::https://hg.mozilla.org/try
git config remote.try.skipDefaultUpdate true
git remote set-url --push try hg::ssh://hg.mozilla.org/try
git config remote.try.push +HEAD:refs/heads/branches/default/tip

# Fetch the tags
git fetch --tags hg::tags: tag "*"

# Default branches are branches/default/tip and origin/branches/default/tip
# but we'll checkout bookmarks/central as master
git remote add mozilla hg::https://hg.mozilla.org/mozilla-unified -t bookmarks/central
git remote update # creates mozilla/bookmarks/central
git checkout -b master --track mozilla/bookmarks/central

# You could check out the tip (inbound?) with
# git checkout -b tip branches/default/tip

sentences=(
	"Hello!"
	"$DESTINATION has been cinnabarified."
	"Now go and enjoy using git instead of hg."
	"Have a wonderful day!"
)

for i in "${sentences[@]}"
do
	echo "$i"
	# TODO detect if 'say' exists before attempting to use it
	# https://github.com/sole/cinnabarify/issues/2
	say "$i"
done

