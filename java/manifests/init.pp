class java {
    file { "/usr/lib/jvm/":
        ensure => "directory",
    }
    exec { "download_java":
        command => "/usr/bin/wget http://eesoft.benco.lt:8080/downloads/jre-7u3-linux-i586.tar.gz",
        cwd => "/usr/lib/jvm/",
        creates => "/usr/lib/jvm/jre-7u3-linux-i586.tar.gz"
    }
    file { "/usr/lib/jvm/jre-7u3-linux-i586.tar.gz":
        mode => 750
    }
    exec {"unzip_java":
        command => "/bin/tar zxvf jre-7u3-linux-i586.tar.gz",
        cwd => "/usr/lib/jvm/",
        creates => "/usr/lib/jvm/jre-7u3-linux-i586",
        require => [Exec["download_java"]]
    }
    exec {"set default jvm":
        command => "/usr/bin/update-alternatives --install /usr/bin/java java /usr/lib/jvm/jre1.7.0_03/bin/java 1",
        unless  => "/usr/bin/test $(readlink /etc/alternatives/java) = /usr/lib/jvm/jre1.7.0_03/bin/java",
    }
}
