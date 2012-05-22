class mule{
	$version = "3.2.1"
	$package = "mule-standalone-$version"
    exec { "download_mule":
        command => "/usr/bin/wget http://dist.codehaus.org/mule/distributions/$package.tar.gz",
        cwd => "/opt",
        creates => "/opt/$package.tar.gz",
        timeout => 3600,
        tries => 3,
        try_sleep => 15
    }
    exec {"unzip_mule":
        command => "/bin/tar zxvf $package.tar.gz",
        cwd => "/opt",
        creates => "/opt/$package",
        require => [Exec["download_mule"]]
    }
	file { '/opt/mule-standalone':
	   ensure => 'link',
           target => "/opt/$package",
	}
	file { '/etc/init.d/mule':
	   ensure => 'link',
           target => "/opt/mule-standalone/bin/mule",
	}
	file { '/etc/rc1.d/K99mule':
	   ensure => 'link',
	   target => '/etc/init.d/mule',
	}
	file { '/etc/rc2.d/S99mule':
	   ensure => 'link',
	   target => '/etc/init.d/mule',
	}
	file { "/opt/mule-standalone/apps":
		ensure => "directory",
		mode => 755,
		owner => $deploy_user,
		group => $deploy_group,
		require => [File['/opt/mule-standalone/apps']]
	}
	file { "/opt/mule-apps":
		ensure => "directory",
		mode => 744,
		owner => $deploy_user,
		group => $deploy_group
	}
#	service { "mule":
#		ensure => "running",
#	}
}