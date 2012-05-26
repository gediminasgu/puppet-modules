class mule{
	$version = "3.2.1"
	$package = "mule-standalone-$version"
	require mule::params
	
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
	file {'mule-service':
		path => "/etc/init.d/mule",
		mode => 755,
		content => template("mule/service.erb"),
		notify => Service[mule]
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
	service { "mule":
		ensure => "running",
	}

	nexus::artifact {'activemq-all':
		gav => "org.apache.activemq:activemq-all:5.6.0",
		repository => "public",
		output => "/opt/mule-standalone/lib/shared/default/activemq-all-5.6.0.jar",
		ensure => present
	}

	nexus::artifact {'com.meterhub.amr.contract':
		gav => "com.meterhub:meterhub.amr-contract:1.0.8",
		repository => "releases",
		output => "/opt/mule-standalone/lib/shared/default/meterhub.amr-contract-1.0.8.jar",
		ensure => present
	}

	nexus::artifact {'jackson-core-asl':
		gav => "org.codehaus.jackson:jackson-core-asl:1.9.7",
		repository => "public",
		output => "/opt/mule-standalone/lib/shared/default/jackson-core-asl-1.9.7.jar",
		ensure => present
	}

	nexus::artifact {'mongo-java-driver':
		gav => "org.mongodb:mongo-java-driver:2.7.3",
		repository => "public",
		output => "/opt/mule-standalone/lib/shared/default/mongo-2.7.2.jar",
		ensure => present
	}

  puppi::check { 'MULE Error Check':
    command => "check_jmx.sh -U service:jmx:rmi:///jndi/rmi://localhost:${mule::params::jmx_port}/jmxrmi -O 'Mule.amr:name=\"application totals\",type=Application' -A ExecutionErrors -w 0 -c 100",
    hostwide => 'yes',
  }

  puppi::check { 'MULE Fatal Error Check':
    command => "check_jmx.sh -U service:jmx:rmi:///jndi/rmi://localhost:${mule::params::jmx_port}/jmxrmi -O 'Mule.amr:name=\"application totals\",type=Application' -A FatalErrors -w 0 -c 3",
    hostwide => 'yes',
  }
}