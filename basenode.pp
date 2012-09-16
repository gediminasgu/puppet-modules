class basenode {
	$sitename = 'Title'
	$mysql_root_pw = 'secure_password'
	$mysql_mhe_user_pw = 'secure_password'
	$deploy_user = 'user'
	$deploy_group = 'user'
	$nexus_user = 'nexus_user'
	$nexus_password = 'nexus_password'
	$nexus_url_base = '127.0.0.1/nexus'
	$downloads_url_base = '127.0.0.1'
	$zabbix_password = 'zabbix_password'
	$zabbix_server = 'zabbix server'
}

class {'nexus':
	url => "http://${nexus_url_base}",
	username => $nexus_user,
	password => $nexus_password,
}
