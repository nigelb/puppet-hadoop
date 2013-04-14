# /etc/puppet/modules/hadoop/manifests/params.pp

class hadoop::params(
	$hadoop_user = "hadoop",
	$hadoop_user_uid = 800,
	$hadoop_group = "hadoop",
	$hadoop_group_gid = 800,

	$version = "1.1.2",
	$master = "master0",
	$slaves = "slave0,slave1,slave2",
	$hdfsport =  8020,
	$replication =  3,
	$jobtrackerport =  8021,
	$java_home =  "/usr/lib/jvm/java",
	$hadoop_base =  "/opt/hadoop",
	$hdfs_path = "UNSET"	
	
) {
	if $hdfs_path == 'UNSET' {
		$real_hdfs_path = "/home/${hadoop::params::hadoop_user}/hdfs"
	}
	else
	{
		$real_hdfs_path = $hdfs_path
	}
}
