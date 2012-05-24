class activemq {
    exec { "download_activemq":
        command => "/usr/bin/wget http://apache.mirror.vu.lt/apache/activemq/apache-activemq/5.6.0/apache-activemq-5.6.0-bin.tar.gz",
        cwd => "/opt",
        creates => "/opt/apache-activemq-5.6.0-bin.tar.gz",
        timeout => 3600,
        tries => 3,
        try_sleep => 15
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
		path => "/etc/init.d/activemq",
		mode => 755,
		content => template("activemq/activemq-service.erb"),
#		notify => Service[activemq]
	}
	file {'activemq-config':
		ensure => present,
		path => "/opt/activemq/conf/activemq.xml",
		mode => 664,
		content => template("activemq/activemq.xml.erb"),
#		notify => Service[activemq]
	}
	file { '/etc/rc2.d/S20activemq':
	   ensure => 'link',
	   target => '/etc/init.d/activemq',
	}
#	service { "activemq":
#		ensure => "running",
#	}
}