class mule(
	$jmx_port = '11100',
	$deploy_user = 'user',
	$deploy_group = 'user',
	$path = '/opt/mule-standalone',
){
	$version = "3.3.0"
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
		before  => Class['mule::is_installed'],
        require => [Exec["download_mule"]]
    }
	file { $path:
	   ensure => 'link',
           target => "/opt/$package",
		before  => Class['mule::is_installed'],
	}
	file {'mule-service':
		path => "/etc/init.d/mule",
		mode => 755,
		content => template("mule/service.erb"),
		before  => Class['mule::is_installed'],
		notify => Exec[mule]
	}
	file { '/etc/rc1.d/K99mule':
	   ensure => 'link',
	   target => '/etc/init.d/mule',
	}
	file { '/etc/rc2.d/S99mule':
	   ensure => 'link',
	   target => '/etc/init.d/mule',
	}
	file { "${path}/apps":
		ensure => "directory",
		mode => 755,
		owner => $deploy_user,
		group => $deploy_group,
		require => [File[$path]]
	}
	file { "/opt/mule-apps":
		ensure => "directory",
		mode => 744,
		owner => $deploy_user,
		group => $deploy_group
	}
	exec { "mule":
		command => "/etc/init.d/mule start 2>&1",
		refresh => "/etc/init.d/mule stop 2>&1; sleep 5; /etc/init.d/mule start 2>&1",
		unless => "/etc/init.d/mule status 2>&1",
		require => [Class['java::is_installed'], Class['mule::is_installed']]
	}

	nexus::artifact {'activemq-all':
		gav => "org.apache.activemq:activemq-all:5.6.0",
		repository => "public",
		output => "${path}/lib/shared/default/activemq-all-5.6.0.jar",
		ensure => present
	}

	nexus::artifact {'jackson-core-asl':
		gav => "org.codehaus.jackson:jackson-core-asl:1.9.7",
		repository => "public",
		output => "${path}/lib/shared/default/jackson-core-asl-1.9.7.jar",
		ensure => present
	}

	nexus::artifact {'mongo-java-driver':
		gav => "org.mongodb:mongo-java-driver:2.7.3",
		repository => "public",
		output => "${path}/lib/shared/default/mongo-2.7.2.jar",
		ensure => present
	}

  puppi::check { 'MULE-Proc-Check':
    command => "check_procs -c 2:2 -a mule",
    hostwide => 'yes',
  }

  puppi::check { 'MULE-Error-Check':
    command => "check_jmx.sh -U service:jmx:rmi:///jndi/rmi://localhost:${jmx_port}/jmxrmi -O 'Mule.amr:name=\"application totals\",type=Application' -A ExecutionErrors -w 0 -c 100",
    hostwide => 'yes',
  }

  puppi::check { 'MULE-Fatal-Error-Check':
    command => "check_jmx.sh -U service:jmx:rmi:///jndi/rmi://localhost:${jmx_port}/jmxrmi -O 'Mule.amr:name=\"application totals\",type=Application' -A FatalErrors -w 0 -c 3",
    hostwide => 'yes',
  }
  puppi::check { 'MULE-JMX-port-Check':
    command => "check_tcp -p ${jmx_port} -r warn",
    hostwide => 'yes',
  }
  
  	puppi::log { "mule":
		description => "Mule log" ,
		log => "/opt/mule-standalone/logs/mule.log",
	}
	
	include mule::is_installed
}