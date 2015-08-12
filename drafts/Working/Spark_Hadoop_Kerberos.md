# Spark Hadoop Kerberos

### References
- [Spark-5342 Allow long running Spark apps to run on secure YARN/HDFS](https://issues.apache.org/jira/browse/SPARK-5342)
- [Long Running Spark Apps on Secure YARN](https://issues.apache.org/jira/secure/attachment/12693526/SparkYARN.pdf)
- [SPARK-6918 Secure HBase with Kerberos does not work over YARN](https://issues.apache.org/jira/browse/SPARK-6918)
- [The Role of Delegation Tokens in Apache Hadoop Security](http://hortonworks.com/blog/the-role-of-delegation-tokens-in-apache-hadoop-security/)
- [Adding Security to Apache Hadoop](http://hortonworks.com/wp-content/uploads/2011/10/security-design_withCover-1.pdf)

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
