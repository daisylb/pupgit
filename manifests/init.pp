class pupgit {
  package {'git':
    ensure => installed,
  }

  package {'rubygems':
    ensure => installed,
  }

  package {'librarian-puppet-maestrodev':
    ensure => installed,
    provider => gem,
    require => Package['rubygems'],
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
      /usr/local/bin/run-puppet
      ',
  }

  file {'/usr/local/bin/run-puppet':
    ensure => present,
    mode => 0700,
    content => '#!/bin/bash
      cd /var/local/puppet
      librarian-puppet install
      puppet apply --modulepath=./modules:./thirdparty manifests/site.pp',
  }

  file {'/root/reapply':
    ensure => absent,
  }
}
