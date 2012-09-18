class activemq {
	require activemq::params
	
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
		notify => Exec["start_activemq"]
	}
	file {'activemq-config':
		ensure => present,
		path => "/opt/activemq/conf/activemq.xml",
		mode => 664,
		content => template("activemq/activemq.xml.erb"),
		require => [Exec['unzip_activemq'], File['/opt/activemq']],
		notify => Exec["start_activemq"]
	}
	file { '/etc/rc2.d/S20activemq':
	   ensure => 'link',
	   target => '/etc/init.d/activemq',
	}
	file { '/etc/rc1.d/K20activemq':
	   ensure => 'link',
	   target => '/etc/init.d/activemq',
	}
	exec { "start_activemq":
		command => "/etc/init.d/activemq start",
		unless => "/etc/init.d/activemq status",
		require => Class['java::is_installed']
	}
	
  puppi::check { 'ACTIVEMQ-Proc-Check':
    command => "check_procs -c 1:1 -a activemq",
    hostwide => 'yes',
  }

  puppi::check { 'ACTIVEMQ-port-Check':
    command => "check_tcp -p 61616 -r critical",
    hostwide => 'yes',
  }

  puppi::check { 'ACTIVEMQ-JMX-port-Check':
    command => "check_tcp -p ${activemq::params::jmx_port} -r warn",
    hostwide => 'yes',
  }

}