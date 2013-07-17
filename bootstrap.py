#!/usr/bin/env python2.7

USAGE = """Usage:
{cmd} FQDN [IP]

FQDN: Fully-qualified domain name of the server to bootstrap
IP  : IP address, in case it's not yet accessible over DNS
"""

try:
    import paramiko
except ImportError:
    print "You need to install paramiko first."
    print "Run `pip install paramiko`."
    exit(1)

import sys
import re
import os

if len(sys.argv) == 3:
    connect = sys.argv[2]
    fqdn = sys.argv[1]
elif len(sys.argv) == 2:
    connect = fqdn = sys.argv[1]
else:
    print "Usage: {} fqdn.of.your.node".format(sys.argv[0])
    exit(2)

# functions

def check_call(ssh, cmd, return_codes=(0,)):
    print cmd
    stdin, stdout, stderr = ssh.exec_command(cmd)
    code = stdout.channel.recv_exit_status()
    if code not in return_codes:
        print "ERROR: exited with code {}".format(code)
        print "stdout:"
        print stdout.read()
        print "stderr:"
        print stderr.read()
        exit(3)
    else:
        return stdin, stdout, stderr, code

# the actual script

hostname, domain = fqdn.split('.', 1)

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
pkey = paramiko.RSAKey.from_private_key_file('/Users/adam/.ssh/work_rsa')
ssh.connect(connect, username='root', pkey=pkey)

# sometimes facter can't read the domain properly unless you do this
check_call(ssh, 'echo "domain {}" >> /etc/resolv.conf'.format(domain))

# install puppet
_, release, _, _ = check_call(ssh, 'cat /etc/lsb-release')
release = re.search(r'DISTRIB_CODENAME=([^\n]+)', release.read()).group(1)
check_call(ssh, 
        "wget -Opuppet.deb http://apt.puppetlabs.com/puppetlabs-release-{}.deb"
        .format(release))
check_call(ssh, "dpkg -i puppet.deb")
check_call(ssh, "rm puppet.deb")
check_call(ssh, "apt-get update")
check_call(ssh, "apt-get install -y puppet")

# upload the bootstrap manifest
print 'Uploading manifest...'
ftp = ssh.open_sftp()
manifest_path = os.path.join(os.path.dirname(__file__), 'manifests', 'init.pp')
ftp.put(manifest_path, 'bootstrap.pp')

# run it
check_call(ssh, 'echo "include pupgit" >> bootstrap.pp')
check_call(ssh, 'puppet apply bootstrap.pp')

print "All done. Now try running this command:"
print "git push ssh://root@{}/var/local/puppet.git master".format(connect)
