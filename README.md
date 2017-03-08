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

## Limitations

Only tested on a Mac OS environment. It's a Bash script.

See the [issues](https://github.com/sole/cinnabarify/issues).

Please be warned that
- I do *not* intend to turn this into a general purpose tool
- I just wrote this to help me and new hires get started, and 
- if you want new features or different behaviours, you're more than welcome to fork this and work in your own version of this script

Please also note that I will gladly accept pull requests that fix the filed issues.
