# /etc/puppet/modules/hadoop/manifests/init.pp
class hadoop {

	require hadoop::params
	require hadoop::cluster

	include hadoop::cluster::master
	include hadoop::cluster::slave

        Exec { path => ["/bin", "/usr/bin"] }

	group { $hadoop::params::hadoop_group:
		ensure => present,
		gid => $hadoop::params::hadoop_group_gid
	}

	user { $hadoop::params::hadoop_user:
		ensure => present,
		comment => "Hadoop",
		password => "!!",
		uid => $hadoop::params::hadoop_user_uid,
		gid => $hadoop::params::hadoop_group_gid,
		shell => "/bin/bash",
		home => "/home/${hadoop::params::hadoop_user}",
		require => Group[$hadoop::params::hadoop_group],
	}
	
	file { "/home/${hadoop::params::hadoop_user}/.bash_profile":
		ensure => present,
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		alias => "hduser-bash_profile",
		content => template("hadoop/home/bash_profile.erb"),
		require => User[$hadoop::params::hadoop_user]
	}
		
	file { "/home/${hadoop::params::hadoop_user}":
		ensure => "directory",
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		alias => "hduser-home",
		require => [ User[$hadoop::params::hadoop_user], Group[$hadoop::params::hadoop_group] ]
	}

	file {"$hadoop::params::real_hdfs_path":
		ensure => "directory",
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		alias => "hdfs-dir",
		require => File["hduser-home"]
	}
	
	file {"$hadoop::params::hadoop_base":
		ensure => "directory",
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		alias => "hadoop-base",
	}
	
	file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}.tar.gz":
		mode => 0644,
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		source => "puppet:///modules/hadoop/hadoop-${hadoop::params::version}.tar.gz",
		alias => "hadoop-source-tgz",
		before => Exec["untar-hadoop"],
		require => File["hadoop-base"]
	}
	
	exec { "untar hadoop-${hadoop::params::version}.tar.gz":
		command => "tar -zxf hadoop-${hadoop::params::version}.tar.gz",
		cwd => "${hadoop::params::hadoop_base}",
		creates => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}",
		alias => "untar-hadoop",
		refreshonly => true,
		subscribe => File["hadoop-source-tgz"],
		user => $hadoop::params::hadoop_user,
		before => [ File["hadoop-symlink"], File["hadoop-app-dir"]]
	}
	file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}":
		ensure => "directory",
		mode => 0644,
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		alias => "hadoop-app-dir"
	}
		
	file { "/etc/hadoop":
		force => true,
		ensure => "link",
		target => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf",
		alias => "etc-hadoop-symlink",
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		require => File["hadoop-source-tgz"],
	}
	file { "/var/log/hadoop":
		force => true,
		ensure => "link",
		target => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/logs",
		alias => "log-hadoop-symlink",
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		require => File["hadoop-source-tgz"],
	}
	
	file { "${hadoop::params::hadoop_base}/hadoop":
		force => true,
		ensure => "link",
		target => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}",
		alias => "hadoop-symlink",
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		require => File["hadoop-source-tgz"],
		before => [ File["core-site-xml"], File["hdfs-site-xml"], File["mapred-site-xml"], File["hadoop-env-sh"] ]
	}
	
	file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/core-site.xml":
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "644",
		alias => "core-site-xml",
		content => template("hadoop/conf/core-site.xml.erb"),
	}
	
	file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/hdfs-site.xml":
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "644",
		alias => "hdfs-site-xml",
		content => template("hadoop/conf/hdfs-site.xml.erb"),
	}
	
	file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/hadoop-env.sh":
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "644",
		alias => "hadoop-env-sh",
		content => template("hadoop/conf/hadoop-env.sh.erb"),
	}

	file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/log4j.properties":
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "644",
		alias => "hadoop-logging-config",
		source => "puppet:///modules/hadoop/conf/log4j.properties",
		require => File["hadoop-app-dir"],
		ensure  => present,
	}

	file { "/etc/profile.d/hadoop.sh":
		mode => "544",
		alias => "hadoop-path",
		content => template("hadoop/profile.d/hadoop.sh.erb"),
	}
	
	exec { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin/hadoop namenode -format":
		user => $hadoop::params::hadoop_user,
		alias => "format-hdfs",
		refreshonly => true,
		subscribe => File["hdfs-dir"],
		require => [ File["hadoop-symlink"], File["hduser-bash_profile"], File["mapred-site-xml"], File["hdfs-site-xml"], File["core-site-xml"], File["hadoop-env-sh"]]
	}
	
	file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/mapred-site.xml":
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "644",
		alias => "mapred-site-xml",
		content => template("hadoop/conf/mapred-site.xml.erb"),		
	}
	
	file { "/home/${hadoop::params::hadoop_user}/.ssh/":
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "700",
		ensure => "directory",
		require => User[$hadoop::params::hadoop_user],
		alias => "hduser-ssh-dir",
	}
	
	file { "/home/${hadoop::params::hadoop_user}/.ssh/id_rsa.pub":
		ensure => present,
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "644",
		source => "puppet:///modules/hadoop/ssh/id_rsa.pub",
		require => File["hduser-ssh-dir"],
		alias => "hadoop-ssh-public-key",
	}
	
	file { "/home/${hadoop::params::hadoop_user}/.ssh/id_rsa":
		ensure => present,
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "600",
		source => "puppet:///modules/hadoop/ssh/id_rsa",
		require => File["hadoop-ssh-public-key"],
		alias => "hadoop-ssh-private-key",
	}
	
	file { "/home/${hadoop::params::hadoop_user}/.ssh/authorized_keys":
		ensure => present,
		owner => $hadoop::params::hadoop_user,
		group => $hadoop::params::hadoop_group,
		mode => "644",
		source => "puppet:///modules/hadoop/ssh/id_rsa.pub",
		require => File["hduser-ssh-dir"],
	}	
}
