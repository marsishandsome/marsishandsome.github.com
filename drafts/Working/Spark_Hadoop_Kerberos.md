# Spark Hadoop Kerberos

### References
- [Spark-5342 Allow long running Spark apps to run on secure YARN/HDFS](https://issues.apache.org/jira/browse/SPARK-5342)
- [Spark-8688 Hadoop Configuration has to disable client cache when writing or reading delegation tokens](https://issues.apache.org/jira/browse/SPARK-8688)
- [Long Running Spark Apps on Secure YARN](https://issues.apache.org/jira/secure/attachment/12693526/SparkYARN.pdf)
- [SPARK-6918 Secure HBase with Kerberos does not work over YARN](https://issues.apache.org/jira/browse/SPARK-6918)
- [The Role of Delegation Tokens in Apache Hadoop Security](http://hortonworks.com/blog/the-role-of-delegation-tokens-in-apache-hadoop-security/)
- [Hadoop Security Design](http://www.valleytalk.org/wp-content/uploads/2013/03/hadoop-security-design.pdf)

### Notes
- --conf spark.hadoop.fs.hdfs.impl.disable.cache=true
- [spark on yarn : job提交重要参数说明](http://www.boywell.com/Spark/job-submit-parameters-setting-of-spark-on-yarn.html)
- [hive由fs.hdfs.impl.disable.cache参数引起的重写分区数据的异常](http://blog.csdn.net/jyl1798/article/details/42521789)

### Spark-1.3
```scala
val credentials = UserGroupInformation.getCurrentUser.getCredentials
Client.obtainTokensForNamenodes
FileSystem.addDelegationTokens
UserGroupInformation.getCurrentUser().addCredentials(credentials)


ContainerLaunchContext.setTokens

val dob = new DataOutputBuffer
credentials.writeTokenStorageToStream(dob)
amContainer.setTokens(ByteBuffer.wrap(dob.getData))
```

```
Kind: YARN_AM_RM_TOKEN, Service: rm1:8030,rm2.:8030, Ident: (org.apache.hadoop.yarn.security.AMRMTokenIdentifier@7a53ac3c)

Kind: HDFS_DELEGATION_TOKEN, Service: ha-hdfs:hadoop-namenode, Ident: (HDFS_DELEGATION_TOKEN token 294431 for test)
```

### Spark-1.4

### Hadoop Delegation Tokens maximum lifetime of 7 days
dfs.namenode.delegation.token.max-lifetime = 3h
dfs.namenode.delegation.key.update-interval = 1h
dfs.namenode.delegation.token.renew-interval = 1h
