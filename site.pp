# cp site.pp /etc/puppet/manifests/
# puppet apply /etc/puppet/manifests/site.pp
node default {
  include java
  include activemq
  include tomcat
}
