# apt-get install git-core
# git clone git://github.com/gediminasgu/puppet-modules.git /etc/puppet/modules
# cd /etc/puppet/modules
# git pull && git submodule init && git submodule update && git submodule status
# ln -s /etc/puppet/modules/site.pp /etc/puppet/manifests/site.pp
# puppet apply /etc/puppet/manifests/site.pp

import 'basenode.pp'
node default {
  require basenode
  include mongodb
  
  class {'java':
  	downloads_url_base => $basenode::downloads_url_base,
  }
  include java
  
  include activemq
  include tomcat
  include jetty
  
  class {'mule':
  	deploy_user => $basenode::deploy_user,
  	deploy_group => $basenode::deploy_group,
  }
  include mule
  
  class {'nexus':
	url => "http://${basenode::nexus_url_base}",
	username => $basenode::nexus_user,
	password => $basenode::nexus_password,
  }
  include nexus
  
  include rabbitmq

  include mysql
  class { 'mysql::server': }
  mysql::db { 'mhe_joomla':
    user     => 'mhe_user',
    password => $basenode::mysql_mhe_user_pw,
    host     => 'localhost',
    grant    => ['all'],
  }
  puppi::check { 'MYSQL-MHEDB-Check':
    command => "check_mysql -d mhe_joomla -u mhe_user -p $basenode::mysql_mhe_user_pw",
    hostwide => 'yes',
  }
  package { 'php5-mysql': ensure => present }
  package { 'ntp': ensure => present }

  include php5_fpm
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

  class {'amr':
  	nexus_user => $basenode::nexus_user,
  	nexus_password => $basenode::nexus_password,
  	nexus_url_base => $basenode::nexus_url_base,
  	mule_jmx_port => $mule::jmx_port,
  }
  include amr
  
  class {'website':
  	downloads_url_base => $basenode::downloads_url_base,
  	deploy_user => $basenode::deploy_user,
  	deploy_group => $basenode::deploy_group,
  	mysql_mhe_user_pw => $basenode::mysql_mhe_user_pw,
  	nexus_user => $basenode::nexus_user,
  	nexus_password => $basenode::nexus_password,
  	nexus_url_base => $basenode::nexus_url_base,
  }
  include website
  
#  class {'zabbix_agent':
#  	zabbix_password => $basenode::zabbix_password,
#  }
#  include zabbix_agent
}
