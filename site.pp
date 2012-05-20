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
  class { 'mysql::server':
    config_hash => {'root_password' => $mysql_root_pw}
  }

}
