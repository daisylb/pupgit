# pupgit

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
