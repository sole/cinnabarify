# cinnabarify

This is a scripted version of the steps you'd follow to get a Mozilla Firefox repository with [git-cinnabar](https://github.com/glandium/git-cinnabar) on it.

Basically, it's like the steps at the [workflow for Gecko development](https://github.com/glandium/git-cinnabar/wiki/Mozilla:-A-git-workflow-for-Gecko-development) page, but automated.

## Usage

```bash
git clone https://github.com/sole/cinnabarify.git
cd cinnabarify
./main.sh /path/to/your/desired/target/directory
```

For example:

```bash
./main.sh ~/Firefox-code
```

will do all sorts of magic to get you a git-enabled copy of Firefox's code that works with mercurial underneath and all sorts of other trickery using `git-cinnabar`

## Using the resulting repository

The result of a successful execution is a git repository that somehow uses hg (Mercurial) underneath via git-cinnabar. But to all effects and purposes, it's a git repository, which means you do not need to learn hg, and can keep using the same workflow you already know about.

Since not everyone is a born-git-expert, I'm going to list a few of the common actions that you might want to do on a day to day basis:

### Updating from `upstream` (getting latest changes from `mozilla-central`):

The script checks out `mozilla/central` as the `master` branch locally. There are hundreds of commits being pushed to that branch every day, so you'll want to pull regularly to ensure your code is written on top of the latest code.

This will bring your local `master` in sync with the last commit in `mozilla-central`:

```bash
git remote update
git checkout master
git pull --rebase mozilla
```

### Work on a bug

I suggest you do the step above before you start working on a bug.

Then, create and switch to a new branch for the bug:

```bash
git checkout -b bug123456789
```

Do your work and everything. If you need to work on another thing, you can add and commit the changes, check out `master` and create another branch from there.

### Pushing to the `try` server

You might want to push your current branch to the testing server to get the test suite run in a number of environments.

The way the environments in which tests are run is decided is by looking at the git commit message. There is a [try syntax builder](https://mozilla-releng.net/trychooser/) that can help you with this.

<!--TODO: add some common try syntaxes-->

Add files to the commit, use the syntax you built as the commit message, and then push:

```bash
git push try
```

This will output various messages, amongst which you'll find a URL linking to the test job you created by pushing to the server. You can visit that to see the status of your tests.

### Submitting patches to MozReview

It's advisable to use the MozReview interface to send patches for review rather than generating a patch and attaching it to Bugzilla, and even better: it's possible to send the patches using the command line!

#### Configuration 

But before you do that, you have to configure the repo you *cinnabarified*.

[Official instructions](http://mozilla-version-control-tools.readthedocs.io/en/latest/mozreview/install.html) are quite detailed, but in short, and using the same example directory `~/Firefox-code`:

```bash
cd ~/Firefox-code/
# Installs version-control-tools in ~/.mozbuild
./mach mercurial-setup
```

Edit your $PATH to include `$HOME/.mozbuild/version-control-tools/git/commands` (perhaps do it by editing your `~/.bashrc` file).

```bash
# still in ~/Firefox-code:
git mozreview configure  # and follow steps...
```

Some more config steps:

```bash
git config --global mozreview.nickname yourIRCnick # e.g. mine is sole
```

If you have a Mozilla LDAP account you can associate it with MozReview and it will allow you to do things such as request code to be merged ("landed"), trigger tests, etc. You run another command:

```bash
ssh -l yourLDAP-not-an-alias@mozilla.com reviewboard-hg.mozilla.org mozreview-ldap-associate
```

This will ask for a Bugzilla API Key. You can manage API keys from the [Bugzilla preferences](https://bugzilla.mozilla.org/userprefs.cgi?tab=apikey).

#### Sending patches to MozReview

Once everything is configured, you can initiate a review process by creating a commit message that contains the nicknames of your desired reviewer(s):

```bash
git add files-you-changed
git commit -m 'Bug 123456789 - Do ABC. r?nickname1,nickname2'
```

You can request reviews for as many people as you need, separated by commas.

And to send it to MozReview:

```bash
git mozreview push
```

It will:

- attach a patch to the bug (you can see this in the Bugzilla bug)
- request reviews from the people you mentioned
- print a URL for the review page. Here you can see the results of the review, respond to comments, etc...

If you're logged in, you can request to build and test the code on the `try` server, and once the reviews are positive, you can also request the code to be landed.

#### Fix a patch that had a typo and re-send again for review

Suppose you requested review of a patch which contained a typo. You can fix it locally, commit the fix and squash the changes into just one commit so it looks like it was right from the beginning:

```bash
# ... fix your typo, save files ...
git add files-with-typo
git commit -m 'typo'
# Now 'undo' the last two commits
git reset --soft HEAD~2
# Commit again with same syntax as before...
git commit -m 'Bug 123456789 - Do ABC. r?nickname1,nickname2'
# And send fixed patch
git mozreview push
```

The system is smart enough to detect it's the same bug, and so the URL for the review page will be the same.

## Limitations

Only tested successfully on a Mac OS environment.

Places where it's been tested unsuccesfully (AKA *it does not work*):
* **Bash on Windows** - [tracked here](https://github.com/sole/cinnabarify/issues/3).

See the [issues](https://github.com/sole/cinnabarify/issues).

Please be warned that
- I do *not* intend to turn this into a general purpose tool
- I just wrote this to help me and new hires get started, and 
- if you want new features or different behaviours, you're more than welcome to fork this and work in your own version of this script

Please also note that I will gladly accept pull requests that fix the filed issues.
