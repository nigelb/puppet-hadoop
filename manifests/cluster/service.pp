

class hadoop::cluster::service {
	require hadoop::params
	file{"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin/ssh_initilize.sh":
		alias   => "ssh-init-script",
		content => template("hadoop/bin/ssh_initilize.sh.erb"),
		require => [File["hadoop-master"], File["hadoop-ssh-private-key"]],
		mode    => 755
	}

	Exec{ path => ["/bin", "/usr/bin", "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin"] }

	exec{"${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin/ssh_initilize.sh":
		alias   => "ssh-init",
		command => "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/bin/ssh_initilize.sh",
		require => File["ssh-init-script"],
		user    => $hadoop::params::hadoop_user,
		group   => $hadoop::params::hadoop_group,
	}

}
