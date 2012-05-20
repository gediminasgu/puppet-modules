class jetty{
	$version = "8.1.3"
	$package = "jetty-hightide-$version.v20120416"

    exec { "download_jetty":
        command => "/usr/bin/wget http://dist.codehaus.org/jetty/jetty-hightide-$version/$package.tar.gz",
        cwd => "/opt",
        creates => "/opt/$package.tar.gz"
    }
    exec {"unzip_jetty":
        command => "/bin/tar zxvf $package.tar.gz",
        cwd => "/opt",
        creates => "/opt/$package",
        require => [Exec["download_jetty"]]
    }
	file { '/opt/jetty':
	   ensure => 'link',
           target => "/opt/$package",
	}
	file { '/etc/init.d/jetty':
	   ensure => 'link',
           target => "/opt/jetty/bin/jetty.sh",
	}
	file { '/etc/rc1.d/K99jetty':
	   ensure => 'link',
	   target => '/etc/init.d/jetty',
	}
	file { '/etc/rc2.d/S99jetty':
	   ensure => 'link',
	   target => '/etc/init.d/jetty',
	}
	file {'jetty-config':
		path => "/opt/jetty/etc/jetty.xml",
		mode => 664,
		content => template("jetty/jetty.xml.erb"),
		require => [File['/opt/jetty/etc/jetty.xml']],
#		notify => Service[jetty]
	}
#	service { "jetty":
#		ensure => "running",
#	}
}