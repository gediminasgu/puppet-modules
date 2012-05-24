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
  puppi::project::maven { "amr":
    source       => "http://192.168.1.124:8088/nexus/content/repositories/releases/com/meterhub/meterhub.amr/",
#    user         => "myappuser",
    zip_root  => "/srv/tomcat/myapp/webapps",
    report_email => "fzr600@gmail.com",
    enable       => "true",
  }
}
