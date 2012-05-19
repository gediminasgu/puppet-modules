class java {
case $architecture {
  i386: {
    $package = "jre-7u3-linux-i586"
  }
  amd64: {
    $package = "jre-7u3-linux-x64"
  }
  default: {
    fail("architecture $artichitecture in not supported")
  }
}

    file { "/usr/lib/jvm/":
        ensure => "directory",
    }
    exec { "download_java":
        command => "/usr/bin/wget http://eesoft.benco.lt:8080/downloads/$package.tar.gz",
        cwd => "/usr/lib/jvm/",
        creates => "/usr/lib/jvm/$package.tar.gz"
    }
        exec {"java_tar_make_executable":
                command => "/bin/chmod a+x /usr/lib/jvm/$package.tar.gz",
        require => [Exec["download_java"]]
        }
    exec {"unzip_java":
        command => "/bin/tar zxvf $package.tar.gz",
        cwd => "/usr/lib/jvm/",
        creates => "/usr/lib/jvm/jre1.7.0_03",
        require => [Exec["java_tar_make_executable"]]
    }
    exec {"set default jvm":
        command => "/usr/bin/update-alternatives --install /usr/bin/java java /usr/lib/jvm/jre1.7.0_03/bin/java 1",
        unless  => "/usr/bin/test $(readlink /etc/alternatives/java) = /usr/lib/jvm/jre1.7.0_03/bin/java",
    }
}
