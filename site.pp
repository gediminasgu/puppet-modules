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
  package { 'ntp': ensure => present }

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
  
  puppi::check { 'WEB-FRONT-test':
    command => 'check_http -H localhost -p 80 -u "/index.php?option=com_content&view=featured&Itemid=101&lang=lt"',
    hostwide => 'yes',
  }

  puppi::check { 'WEB-ManagementAPI-test':
    command => 'check_http -H localhost -p 8080 -u "/managementapi/classificators/protocols"',
    hostwide => 'yes',
  }

  puppi::check { 'WEB-DatawarehouseAPI-test':
    command => 'check_http -H localhost -p 8080 -u "/datawarehouse/data"',
    hostwide => 'yes',
  }

  include amr
  include website
  include zabbix-agent
}
