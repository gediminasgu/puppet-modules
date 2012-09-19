class tomcat{
	$version = "7.0.29"
	$package = "apache-tomcat-$version"
    exec { "download_tomcat":
        command => "/usr/bin/wget http://apache.mirror.vu.lt/apache/tomcat/tomcat-7/v$version/bin/$package.tar.gz",
        cwd => "/usr/local",
        creates => "/usr/local/$package.tar.gz"
    }
    exec {"unzip_tomcat":
        command => "/bin/tar zxvf $package.tar.gz",
        cwd => "/usr/local",
        creates => "/usr/local/$package",
        require => [Exec["download_tomcat"]],
		before => Class['tomcat::is_installed'],
    }
	file { '/usr/local/tomcat':
		ensure => 'link',
        target => "/usr/local/$package",
		before => Class['tomcat::is_installed'],
	}
	file {'tomcat-service':
		ensure => present,
		path => "/etc/init.d/tomcat",
		mode => 755,
		content => template("tomcat/tomcat-service.erb"),
		before => Class['tomcat::is_installed'],
		notify => Exec[tomcat]
	}
	file { '/etc/rc1.d/K99tomcat':
	   ensure => 'link',
	   target => '/etc/init.d/tomcat',
		before => Class['tomcat::is_installed'],
	}
	file { '/etc/rc2.d/S99tomcat':
	   ensure => 'link',
	   target => '/etc/init.d/tomcat',
		before => Class['tomcat::is_installed'],
	}
	exec { "tomcat":
		unless => "/etc/init.d/tomcat status",
		command => "/etc/init.d/tomcat start 2>&1",
		refresh => "/etc/init.d/tomcat stop 2>&1; sleep 5; /etc/init.d/tomcat start 2>&1",
		require => [Class['java::is_installed'], Class['tomcat::is_installed']]
	}
  	file { '/usr/local/tomcat/webapps/ROOT':
	   ensure => absent,
	   force => true,
	}
  	file { '/usr/local/tomcat/webapps/manager':
	   ensure => absent,
	   force => true,
	}
  	file { '/usr/local/tomcat/webapps/docs':
	   ensure => absent,
	   force => true,
	}
  	file { '/usr/local/tomcat/webapps/examples':
	   ensure => absent,
	   force => true,
	}
  	file { '/usr/local/tomcat/webapps/host-manager':
	   ensure => absent,
	   force => true,
	}

	puppi::check { 'Tomcat-Proc-Check':
		command => "check_procs -c 1:1 -a tomcat",
		hostwide => 'yes',
	}
	puppi::log { "tomcat":
		description => "Tomcat log" ,
		log => "/usr/local/tomcat/logs/catalina.out",
	}

	include tomcat::is_installed
}