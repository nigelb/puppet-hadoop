# /etc/puppet/modules/hadoop/manifests/cluster/master.pp

class hadoop::cluster::master {
	
        file { "${hadoop::params::hadoop_base}/hadoop-${hadoop::params::version}/conf/masters":
                owner => $hadoop::params::hadoop_user,
                group => $hadoop::params::hadoop_group,
		mode => "644",
		alias => "hadoop-master",
		content => template("hadoop/conf/masters.erb"),		
	}

}

