

class hadoop::cluster::service {

	file{"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin/ssh_initilize.sh":
		alias   => "ssh-init-script"
		content => template("hadoop/bin/ssh_initilize.sh.erb"),
		require => File["hadoop-master"],
		mode    => 744
	}

	Exec{ path => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin"] }

	exec{"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin/ssh_initilize.sh":
		alias   => "ssh-init"
		command => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin/ssh_initilize.sh"
		require => File["ssh-init-script"],
		user    => $hadoop::params::hadoop_user,
		group   => $hadoop::params::hadoop_group,
	}

}
