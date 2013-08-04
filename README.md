# pupgit

Sets up a "masterless" Puppet installation using Git hooks. Just push your
Puppet environment to a Git remote on your host.

## Get It

To install, on your server, run:

```
wget https://rawgithub.com/adambrenecki/pupgit/master/manifests/init.pp; echo "include pupgit" >> init.pp; puppet apply init.pp; rm init.pp
```

If you get an error message from Rubygems about building native extensions, when
puppet tries to install librarian-puppet, the fix is this: `sudo shutdown -r
now`. I don't know why.

For your convenience, the bootstrap script I use is located at `bootstrap.py` in
this repository. It does the above, but also installs Puppet beforehand,
and puts the server's domain in `resolv.conf` (without which Puppet won't
run on Ubuntu 10.04).

## Use It

Just set up a Git repo with your Puppet stuff in it. Note that Pupgit uses
(maestrodev's fork of) [librarian-puppet], which manages your `modules`
directory for you, so any Puppet modules you want to keep in this repo should go
in e.g. `private/`, and be included in your `Puppetfile` as a `:path`.

[librarian-puppet]: http://blog.csanchez.org/2013/01/24/managing-puppet-modules-with-librarian-puppet/

```
# Make a Git repo.
git init puppet-config
cd puppet-config

# Put your puppet config in it.
mkdir manifests
vim manifests/site.pp

# Set up librarian-puppet.
librarian-puppet init
vim Puppetfile
librarian-puppet install

# Push.
git commit -a
git push ssh://root@your.host/var/local/puppet.git
```
