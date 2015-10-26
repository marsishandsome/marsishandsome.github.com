# Hadoop Security (Kerberos)

---
# Hadoop Security (Kerberos)
- Kerberos
- Hadoop HDFS Security
- Spark Security
- Hadoop Security Programming API

---
# Kerberos
![](http://g.hiphotos.baidu.com/baike/c0%3Dbaike92%2C5%2C5%2C92%2C30/sign=0f03a3c4a344ad343ab28fd5b1cb6791/a5c27d1ed21b0ef485f59977dfc451da81cb3efd.jpg)

---
# Kerberos: The Network Authentication Protocol
- [The MIT Kerberos Administrator’s How-to Guide](http://www.kerberos.org/software/adminkerberos.pdf)

![](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Kerberos.svg/440px-Kerberos.svg.png)

---
![](../../../images/kerberos/kerberos1.PNG)

---
# Step 1: TGT Delivery

![](../../../images/kerberos/kerberos2.PNG)

# Step 2: TGS Delivery
---
![](../../../images/kerberos/kerberos3.PNG)

---
![](../../../images/kerberos/kerberos4.PNG)


---
# Hadoop HDFS Security

---
# Hadoop
- [Hadoop Security Design](http://www.valleytalk.org/wp-content/uploads/2013/03/hadoop-security-design.pdf)

![](../../../images/kerberos/hadoop.PNG)

---
#HDFS Delegation Token
- TokenID = {ownerID, renewerID, issueDate, maxDate, sequenceNumber}
- TokenAuthenticator = HMAC-SHA1(masterKey, TokenID)
- Delegation Token = {TokenID, TokenAuthenticator}

---
#Block Access Token
- TokenID = {expirationDate, keyID, ownerID, blockID, accessModes}
- TokenAuthenticator = HMAC-SHA1(key, TokenID)
- Block Access Token = {TokenID, TokenAuthenticator}

---
# Spark Security

---
# Spark Security (Old Design)

![](../../../images/kerberos/spark1.PNG)

---
# Spark Security (New Design)
- [Long Running Spark Apps on Secure YARN](https://issues.apache.org/jira/secure/attachment/12693526/SparkYARN.pdf)

![](../../../images/kerberos/spark2.PNG)

---
# Related Patches
### Allow Long Running Spark Apps
- Spark-1.4.0: [Spark-5342 Allow long running Spark apps to run on secure YARN/HDFS](https://issues.apache.org/jira/browse/SPARK-5342)
- Spark-1.4.0: [SPARK-6918 Secure HBase with Kerberos does not work over YARN](https://issues.apache.org/jira/browse/SPARK-6918)
- Spark-1.5.0: [Spark-8688 Hadoop Configuration has to disable client cache when writing or reading delegation tokens](https://issues.apache.org/jira/browse/SPARK-8688)
- Spark-1.5.0: [Spark-7524 add configs for keytab and principal, move originals to internal](https://issues.apache.org/jira/browse/SPARK-7524)

### Submit Patches
- [Spark-11182 HDFS Delegation Token will be expired when calling "UserGroupInformation.getCurrentUser.addCredentials" in HA mode](https://issues.apache.org/jira/browse/SPARK-11182)
- [HDFS-9276 Failed to Update HDFS Delegation Token for long running application in HA mode](https://issues.apache.org/jira/browse/HDFS-9276)

---
# Configuring YARN for Long-running Applications (Hadoop 2.6.0)
- [Configuring YARN for Long-running Applications](http://www.cloudera.com/content/www/en-us/documentation/enterprise/5-3-x/topics/cm_sg_yarn_long_jobs.html)
- [Yarn-2704  Localization and log-aggregation will fail if hdfs delegation token expired after token-max-life-time](https://issues.apache.org/jira/browse/YARN-2704)
- [Yarn-2704 Github](https://github.com/apache/hadoop/commit/a16d022ca4313a41425c8e97841c841a2d6f2f54?diff=split)

---
# Programming API
