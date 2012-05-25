node basenode {
	$mysql_root_pw = 'secure_password'
	$mysql_mhe_user_pw = 'secure_password'
	$deploy_user = 'user'
	$deploy_group = 'user'
	$nexus_user = 'nexus_user'
	$nexus_password = 'nexus_password'
	
  class {'nexus':
    url => "http://192.168.1.124:8088/nexus",
    username => $nexus_user,
    password => $nexus_password,
  }

}