class pupgit {
  package {'git':
    ensure => installed,
  }

  file {'/var/local/puppet.git':
    ensure => directory,
  }

  file {'/var/local/puppet':
    ensure => directory,
  }

  exec {'create_puppet_git':
    cwd => '/var/local/puppet.git',
    command => '/usr/bin/git init --bare',
    creates => '/var/local/puppet.git/HEAD',
    require => [
      Package['git'],
      File['/var/local/puppet.git'],
    ],
  }

  exec {'create_puppet_working_git':
    cwd => '/var/local/puppet',
    command => '/usr/bin/git init',
    creates => '/var/local/puppet/.git/HEAD',
    require => [
      Package['git'],
      File['/var/local/puppet'],
    ],
  }

  file {'/var/local/puppet.git/hooks/post-receive':
    ensure => present,
    require => Exec['create_puppet_git'],
    mode => 0700,
    content => '#!/bin/bash
      set -e
      unset GIT_DIR
      cd /var/local/puppet
      git fetch /var/local/puppet.git master -q
      git reset --hard FETCH_HEAD -q
      git submodule update --init --recursive -q
      /root/reapply
      ',
  }

  file {'/root/reapply':
    ensure => present,
    mode => 0700,
    content => '#!/bin/bash
      puppet apply --modulepath=/var/local/puppet/modules:/var/local/puppet/thirdparty /var/local/puppet/manifests/site.pp',
  }
}
