class zabbix-agent {

  $version = "2.0.0"
  $config_dir = "/etc/zabbix/"
  $zabbix_install_dir = "/opt/zabbix/"
  $zabbix_agentd_conf = "$config_dir/zabbix_agentd.conf"
  $zabbix_user_home_dir = "/var/lib/zabbix"

case $architecture {
  i386: {
    $package = "zabbix_agents_$version.linux2_6_23.i386"
  }
  amd64: {
    $package = "zabbix_agents_$version.linux2_6_23.amd64"
  }
  default: {
    fail("architecture $artichitecture in not supported")
  }
}

    file { $config_dir:
        ensure => "directory",
		owner 	=> root,
        group 	=> root,
        mode 	=> 755,
    }

    file { $zabbix_install_dir:
        ensure => "directory",
		owner 	=> root,
        group 	=> root,
        mode 	=> 755,
    }

    exec { "zabbix_download":
        command => "/usr/bin/wget http://www.zabbix.com/downloads/$version/$package.tar.gz",
        cwd => $zabbix_install_dir,
        creates => "$zabbix_install_dir$package.tar.gz",
        timeout => 3600,
        tries => 3,
        try_sleep => 15,
        require => [ File[$zabbix_install_dir] ]
    }

    exec {"zabbix_untar":
        command => "/bin/tar zxvf $package.tar.gz",
        cwd => $zabbix_install_dir,
        creates => "$zabbix_install_dir/sbin",
        require => [Exec["zabbix_download"]]
    }
	
	file { $zabbix_agentd_conf:
            owner 	=> root,
            group 	=> root,
            mode 	=> 644,
            content => template("zabbix-agent/zabbix_agentd_conf.erb"),
			notify	=> Service['zabbix_agentd'],
            require => [ File["$config_dir"] ];
	}

	file { "/etc/init.d/zabbix-agent":
		owner 	=> root,
		group 	=> root,
		mode => 755,
		content => template("zabbix-agent/zabbix_agent_service.erb"),
		notify	=> Service['zabbix_agentd'],
		require => [ File["$config_dir"] ];
	}
	file { '/etc/rc1.d/K20zabbix-agent':
	   ensure => 'link',
	   target => '/etc/init.d/zabbix-agent',
	}
	file { '/etc/rc2.d/S20zabbix-agent':
	   ensure => 'link',
	   target => '/etc/init.d/zabbix-agent',
	}

	service {
        "zabbix_agentd":
            enable 		=> true,
            ensure 		=> running,
			hasstatus	=> false,
			hasrestart	=> true,
            require 	=> [ File[$config_dir], Exec["zabbix_untar"], File["/etc/init.d/zabbix-agent"] ];
    }
	
	user { 'zabbix':
		ensure		=> 'present',
		home		=> $zabbix_user_home_dir,
		password    => $zabbix_password,
		shell       => '/bin/bash',
		gid			=> 'zabbix',
		managehome	=> 'true',	
	}
	
	group { 'zabbix':
		ensure => 'present',
	}
	
    file { $zabbix_user_home_dir:
		ensure 	=> directory,
		owner 	=> zabbix,
		group 	=> zabbix,
		mode 	=> 700,
		require => User["zabbix"];
	}

}
