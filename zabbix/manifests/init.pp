class zabbix-agent {
case $architecture {
  $version = "2.0.0"
  $config_dir = "/etc/zabbix/"
  $install_dir = "/opt/zabbix/"
  $zabbix_agentd_conf = "$config_dir/zabbix_agentd.conf"
  $zabbix_user_home_dir = "/var/lib/zabbix"
  
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

    file { $install_dir:
        ensure => "directory",
		owner 	=> root,
        group 	=> root,
        mode 	=> 755,
    }

    exec { "download":
        command => "/usr/bin/wget http://www.zabbix.com/downloads/$version/$package.tar.gz",
        cwd => "$install_dir",
        creates => "$install_dir$package.tar.gz",
        timeout => 3600,
        tries => 3,
        try_sleep => 15,
        require => [ File["$install_dir"] ]
    }

    exec {"untar":
        command => "/bin/tar zxvf $package.tar.gz",
        cwd => install_dir",
        creates => "$install_dir/sbin",
        require => [Exec["download"]]
    }
	
	file { $zabbix_agentd_conf:
            owner 	=> root,
            group 	=> root,
            mode 	=> 644,
            content => template("zabbix/zabbix_agentd_conf.erb"),
			notify	=> Service['zabbix_agentd'],
            require => [ File["$config_dir"] ];
	}

	file { "/etc/init.d/zabbix-agent":
		owner 	=> root,
		group 	=> root,
		mode 	=> 644,
		content => template("zabbix/zabbix_agent_service.erb"),
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
            require 	=> [ File["$zabbix_config_dir"], Exec["untar"], File["/etc/init.d/zabbix-agent"] ];
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
	
    $zabbix_user_home_dir:
		ensure 	=> directory,
		owner 	=> zabbix,
		group 	=> zabbix,
		mode 	=> 700,
		require => User["zabbix"];
	}

}
