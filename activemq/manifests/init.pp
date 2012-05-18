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
	file { '/etc/init.d/activemq':
	   ensure => 'link',
	   target => '/opt/activemq/bin/activemq',
	}
	file { '/etc/rc2.d/S20activemq':
	   ensure => 'link',
	   target => '/etc/init.d/activemq',
	}
	service { "activemq":
		ensure => "running",
	}
}