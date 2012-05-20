# git submodule add git://github.com/puppetlabs/puppetlabs-mysql.git
# mv puppetlabs-mysql mysql
# ln site.pp /etc/puppet/manifests/site.pp
# puppet apply /etc/puppet/manifests/site.pp

import 'basenode.pp'
node default inherits basenode {
  include mongodb
  include java
  include activemq
  include tomcat
  include jetty
  include mule

  include mysql
  class { 'mysql::server': }
  mysql::db { 'mhe_joomla':
    user     => 'mhe_user',
    password => $mysql_mhe_user_pw,
    host     => 'localhost',
    grant    => ['all'],
  }
}
