# mv site.pp /etc/puppet/manifests/
node default {
  include java
  include activemq
}
