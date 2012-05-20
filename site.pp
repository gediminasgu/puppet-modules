# git submodule add git://github.com/duritong/puppet-mysql.git
# cp site.pp /etc/puppet/manifests/
# puppet apply /etc/puppet/manifests/site.pp
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
