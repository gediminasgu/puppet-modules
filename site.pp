# git submodule add git://github.com/puppetlabs/puppetlabs-mysql.git /etc/puppet/modules/mysql
# git submodule add git://github.com/garthk/puppet-rabbitmq.git /etc/puppet/modules/rabbitmq
# git submodule add git://github.com/BenoitCattie/puppet-nginx.git /etc/puppet/modules/nginx
# git submodule add git://github.com/BenoitCattie/puppet-php5-fpm.git /etc/puppet/modules/php5-fpm
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
}
