class activemq {
    exec { "download_activemq":
        command => "/usr/bin/wget http://apache.mirror.vu.lt/apache/activemq/apache-activemq/5.6.0/apache-activemq-5.6.0-bin.tar.gz",
        cwd => "/opt",
        creates => "/opt/apache-activemq-5.6.0-bin.tar.gz"
    }
    exec {"unzip_activemq":
        command => "/bin/tar zxvf apache-activemq-5.6.0-bin.tar.gz",
        cwd => "/opt",
        creates => "/opt/apache-activemq-5.6.0",
        require => [Exec["download_activemq"]]
    }
	file { '/opt/activemq':
	   ensure => 'link',
	   target => '/opt/apache-activemq-5.6.0',
	}
	file {'activemq-service':
		path => "/etc/activemq/activemq-stop",
		mode => 755,
		content => template("activemq/activemq-stop.erb"),
	}
	file {'activemq-service':
		path => "/etc/init.d/activemq",
		mode => 755,
		content => template("activemq/activemq-service.erb"),
		require => [File['/etc/activemq/activemq-stop']]
		notify => Service[activemq]
	}
	file { '/etc/rc2.d/S20activemq':
	   ensure => 'link',
	   target => '/etc/init.d/activemq',
	}
	service { "activemq":
		ensure => "running",
	}
}