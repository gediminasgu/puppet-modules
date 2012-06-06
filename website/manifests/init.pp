# Class: website
#
# This module manages website
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class website {
    $package = "20120605"
    $sqlpackage = "20120605"

	file { "/var/www":
	    ensure => "directory",
	}

	file { "/var/www/joomla":
	    ensure => "directory",
	    require => [File["/var/www"]]
	}

    exec { "download":
        command => "/usr/bin/wget http://eesoft.benco.lt:8080/downloads/joomla_$package.zip",
        cwd => "/var/www/joomla/",
        creates => "/var/www/joomla/joomla_$package.zip",
        timeout => 3600,
        tries => 3,
        try_sleep => 15,
	    require => [File["/var/www/joomla"]]
    }

    exec {"unzip":
        command => "/usr/bin/unzip joomla_$package.zip",
        cwd => "/var/www/joomla/",
        creates => "/var/www/joomla/index.php",
        require => [Exec["download"]]
    }

	file {'configuration':
		ensure => present,
		path => "/var/www/joomla/configuration.php",
		mode => 755,
		content => template("website/configuration.php.erb"),
        require => [Exec["unzip"]]
	}

	include puppi
	include puppi::prerequisites
	puppi::project::mysql { "sql":
        init_source      => "http://eesoft.benco.lt:8080/downloads/joomla_$sqlpackage.sql",
		source           => "http://eesoft.benco.lt:8080/downloads/no.sql",
        mysql_user       => "mhe_user",
        mysql_host       => "localhost",
        mysql_database   => "mhe_joomla",
        mysql_password   => "$mysql_mhe_user_pw",
        enable           => "true",
    }
}
