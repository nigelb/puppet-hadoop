# /etc/puppet/modules/hadoop/manifests/params.pp

class hadoop::params {

	$version = extlookup("version")
	$master = extlookup("master")
	$slaves = extlookup("slaves")
	$hdfsport =  extlookup("hdfsport")
	$replication =  extlookup("replication")
	$jobtrackerport =  extlookup("jobtrackerport")
	$java_home =  extlookup("java_home")
	$hadoop_base =  extlookup("hadoop_base")
	$hdfs_path =  extlookup("hdfs_path")
	
	$hadoop_user = extlookup("hadoop_user")
	$hadoop_user_uid = extlookup("hadoop_user_uid")
	$hadoop_group = extlookup("hadoop_group")
	$hadoop_group_gid = extlookup("hadoop_group_gid")
}
