class mongodb {
	include mongodb::params
	
	package { "python-software-properties":
		ensure => installed,
	}
	
	exec { "10gen-apt-repo":
		path => "/bin:/usr/bin",
		command => "echo '${mongodb::params::repository}' >> /etc/apt/sources.list",
		unless => "cat /etc/apt/sources.list | grep 10gen",
		require => Package["python-software-properties"],
	}
	
	exec { "10gen-apt-key":
		path => "/bin:/usr/bin",
		command => "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10",
		unless => "apt-key list | grep 10gen",
		require => Exec["10gen-apt-repo"],
	}
	
	exec { "update-apt":
		path => "/bin:/usr/bin",
		command => "apt-get update",
		unless => "ls /usr/bin | grep mongo",
		require => Exec["10gen-apt-key"],
        timeout => 3600,
        tries => 3,
        try_sleep => 15
	}

	package { $mongodb::params::package:
		ensure => installed,
		require => Exec["update-apt"],
	}
	
	service { "mongodb":
		enable => true,
		ensure => running,
		require => Package[$mongodb::params::package],
	}
	
	define replica_set {
		file { "/etc/init/mongodb.conf":
			content => template("mongodb/mongodb.conf.erb"),
			mode => "0644",
			notify => Service["mongodb"],
			require => Package[$mongodb::params::package],
		}
	}
	
  puppi::check { 'MongoDB-Proc-Check':
    command => "check_procs -c 1:1 -C mongod",
    hostwide => 'yes',
  }

}
