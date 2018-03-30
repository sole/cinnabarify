#!/bin/bash

# if user has homebrew installed, install all dependencies
if [ -x "$(command -v brew)" ]; then
    brew install git hg git-cinnabar
fi

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

if ! git cinnabar; then
  echo 'Error: git cinnabar is not installed.' >&2
  exit 1
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

# Start by creating empty git repo
git init "$1"
cd "$1" || exit

# Get native helper for faster operations
# If there's an error, the status code (available in the $? variable) is 1
# so we'll try to install requests... and grab the native helper again (aghhh)
if ! git cinnabar download; then
	echo "Attempting to install requests"
	pip install requests
	git cinnabar download
fi

# Various configs for git-cinnabar to be happy
git config fetch.prune true
git config push.default upstream
git remote add mozilla hg::https://hg.mozilla.org/mozilla-unified -t bookmarks/central
git remote set-url --push mozilla hg::ssh://hg.mozilla.org/integration/mozilla-inbound

# Setup a remote for the try server:
git remote add try hg::https://hg.mozilla.org/try
git config remote.try.skipDefaultUpdate true
git remote set-url --push try hg::ssh://hg.mozilla.org/try
git config remote.try.push +HEAD:refs/heads/branches/default/tip

# Setup a remote for the mozreview server, so you can apply WIP patches locally
git remote add mozreview hg::https://reviewboard-hg.mozilla.org/gecko
git config remote.mozreview.skipDefaultUpdate true

# Update ALL THE REMOTES!!!
echo "☕️ ☕️ ☕️   About to download a  G I G A N T I C  amount of data!!"
echo "Better grab a cup of your favourite hot beverage, or go do something else... life is too short to wait for hg pulls to finish!"
git remote update

# We have fetched the remotes but we haven't checked out anything yet!
# This checks out mozilla/central as our master branch locally
git checkout --track -b master mozilla/central

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

