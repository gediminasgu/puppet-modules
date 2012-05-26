# apt-get install git-core
# git clone git://github.com/gediminasgu/puppet-modules.git /etc/puppet/modules
# cd /etc/puppet/modules
# git pull && git submodule init && git submodule update && git submodule status
# ln -s /etc/puppet/modules/site.pp /etc/puppet/manifests/site.pp
# puppet apply /etc/puppet/manifests/site.pp

import 'basenode.pp'
node default inherits basenode {
  include mongodb
  include java
  include activemq
  include tomcat
  include jetty
  include mule
  include rabbitmq

  include mysql
  class { 'mysql::server': }
  mysql::db { 'mhe_joomla':
    user     => 'mhe_user',
    password => $mysql_mhe_user_pw,
    host     => 'localhost',
    grant    => ['all'],
  }
  puppi::check { 'MYSQL-MHEDB-Check':
    command => "check_mysql -d mhe_joomla -u mhe_user -p $mysql_mhe_user_pw",
    hostwide => 'yes',
  }
  package { 'php5-mysql': ensure => present }

  include php5-fpm
  include nginx
  include nginx::fcgi
  nginx::fcgi::site {"default":
	root            => "/var/www/joomla",
	fastcgi_pass    => "127.0.0.1:9000",
	server_name     => ["localhost", "$hostname", "$fqdn"],
  }
  
  package { 'zip': ensure => present }
  package { 'unzip': ensure => present }
  package { 'sendmail': ensure => present }

  include puppi
  include puppi::prerequisites
  
  require mule::params
  puppi::project::maven { "amr":
    source       => "http://$nexus_user:$nexus_password@192.168.1.124:8088/nexus/content/repositories/releases/com/meterhub/meterhub.amr/",
#    user         => "myappuser",
    zip_root  => "/opt/mule-standalone/apps/amr",
    report_email => "fzr600@gmail.com",
    enable       => "true",
	check_deploy => "no",
	postdeploy_customcommand => "/etc/puppi/scripts/check_version.sh ${mule::params::jmx_port} com.meterhub.amr:type=Monitoring",
	always_deploy => "no",
#	auto_deploy => true,
  }

  puppi::log { "amr":
    description => "AMR Mule log" ,
    log => "/opt/mule-standalone/logs/mule-app-amr.log",
  }
}
