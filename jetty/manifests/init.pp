class jetty{
	$version = "8.1.3"
	$package = "jetty-hightide-$version.v20120416"

    exec { "download_jetty":
        command => "/usr/bin/wget http://dist.codehaus.org/jetty/jetty-hightide-$version/$package.tar.gz",
        cwd => "/opt",
        creates => "/opt/$package.tar.gz",
        timeout => 3600,
        tries => 3,
        try_sleep => 15
    }

    exec {"unzip_jetty":
        command => "/bin/tar zxvf $package.tar.gz",
        cwd => "/opt",
        creates => "/opt/$package",
		before  => Class['jetty::is_installed'],
        require => [Exec["download_jetty"]]
    }

	file { '/opt/jetty':
	    ensure => 'link',
        target => "/opt/$package",
		before  => Class['jetty::is_installed'],
	}

	file { '/etc/init.d/jetty':
	    ensure => 'link',
        target => "/opt/jetty/bin/jetty.sh",
		before  => Class['jetty::is_installed'],
	}

	file { '/etc/rc1.d/K99jetty':
	    ensure => 'link',
	    target => '/etc/init.d/jetty',
		before  => Class['jetty::is_installed'],
	}

	file { '/etc/rc2.d/S99jetty':
	    ensure => 'link',
	    target => '/etc/init.d/jetty',
	}

	file {'jetty-config':
		ensure => present,
		path => "/opt/jetty/etc/jetty.xml",
		mode => 664,
		content => template("jetty/jetty.xml.erb"),
		before  => Class['jetty::is_installed'],
		notify => Service[jetty]
	}

	service { "jetty":
		ensure => "running",
		require => [Class['java::is_installed'], Class['jetty::is_installed']]
	}
	
	file { "/opt/jetty/jetty_log_symlink.sh":
      source => "puppet:///modules/jetty/jetty_log_symlink.sh",
	  mode => 555,
    }
	cron { logrotate:
	  command => "/opt/jetty/jetty_log_symlink.sh",
	  user => root,
	  hour => 0,
	  minute => 0
	}
	
	file { '/opt/jetty/webapps/async-rest':
	   ensure => absent,
	   force => true,
		before  => Class['jetty::is_installed'],
	}

	file { '/opt/jetty/webapps/cometd.war':
	   ensure => absent,
	   force => true,
		before  => Class['jetty::is_installed'],
	}

	file { '/opt/jetty/webapps/root':
	   ensure => absent,
	   force => true,
		before  => Class['jetty::is_installed'],
	}

	file { '/opt/jetty/webapps/spdy.war':
	   ensure => absent,
	   force => true,
		before  => Class['jetty::is_installed'],
	}

	file { '/opt/jetty/webapps/test-annotations':
	   ensure => absent,
	   force => true,
		before  => Class['jetty::is_installed'],
	}

	file { '/opt/jetty/webapps/test-jaas':
	   ensure => absent,
	   force => true,
		before  => Class['jetty::is_installed'],
	}

	file { '/opt/jetty/webapps/test-jndi':
	   ensure => absent,
	   force => true,
		before  => Class['jetty::is_installed'],
	}

	file { '/opt/jetty/webapps/test.war':
	    ensure => absent,
	    force => true,
		before  => Class['jetty::is_installed'],
	}
	
	puppi::check { 'JETTY-Proc-Check':
		command => "check_procs -c 1:1 -a jetty",
		hostwide => 'yes',
	}

  	puppi::log { "jetty":
		description => "Jetty log" ,
		log => "/opt/jetty/logs/stderrout.log",
	}
	
	include jetty::is_installed
}
