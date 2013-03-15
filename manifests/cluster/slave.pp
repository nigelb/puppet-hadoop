# /etc/puppet/modules/hadoop/manifests/cluster/master.pp

class hadoop::cluster::slave {
        file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/slaves":
                owner => $hadoop::params::hadoop_user,
                group => $hadoop::params::hadoop_group,
		mode => "644",
		alias => "hadoop-slave",
		content => template("hadoop/conf/slaves.erb"),		
	}
}
