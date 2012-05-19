class tomcat {
    exec { "download_tomcat":
        command => "/usr/bin/wget http://apache.mirror.vu.lt/apache/tomcat/tomcat-7/v7.0.25/bin/apache-tomcat-7.0.25.tar.gz",
        cwd => "/usr/local",
        creates => "/usr/local/apache-tomcat-7.0.25.tar.gz"
    }
    exec {"unzip_tomcat":
        command => "/bin/tar zxvf apache-tomcat-7.0.25.tar.gz",
        cwd => "/usr/local",
        creates => "/usr/local/apache-tomcat-7.0.25",
        require => [Exec["download_tomcat"]]
    }
	file { '/usr/local/tomcat':
	   ensure => 'link',
	   target => '/usr/local/apache-tomcat-7.0.25',
	}
	file {'tomcat-service':
		path => "/etc/init.d/tomcat",
		mode => 755,
		content => template("tomcat/tomcat-service.erb"),
#		notify => Service[tomcat]
	}
	file { '/etc/rc1.d/K99tomcat':
	   ensure => 'link',
	   target => '/etc/init.d/tomcat',
	}
	file { '/etc/rc2.d/S99tomcat':
	   ensure => 'link',
	   target => '/etc/init.d/tomcat',
	}
#	service { "tomcat":
#		ensure => "running",
#	}
}