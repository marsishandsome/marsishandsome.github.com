# Zeppelin

### Reference
- [官网](https://zeppelin.incubator.apache.org/)
- [Github](https://github.com/apache/incubator-zeppelin)
- [Jira](https://issues.apache.org/jira/browse/ZEPPELIN/?selectedTab=com.atlassian.jira.jira-projects-plugin:roadmap-panel)
- [Document](http://zeppelin.incubator.apache.org/docs/index.html)
- [Introduction to Zeppelin](http://events.linuxfoundation.org/sites/events/files/slides/Zeppelin_ApacheCon2015_0.pdf)
- [Apache Zeppelin安装及介绍](http://blog.csdn.net/pelick/article/details/45934993)

### Install
##### 0. Prepare
install npm
```
wget http://nodejs.org/dist/v0.12.4/node-v0.12.4-linux-x64.tar.gz
tar zxvf node-v0.12.4-linux-x64.tar.gz
cd node-v0.12.4-linux-x64.tar.gz
ln -s `pwd`/bin/node /usr/bin/
ln -s `pwd`/bin/npm /usr/bin/npm
```

config npm
```
npm config set registry=http://registry.npmjs.org/
npm set strict-ssl false
# npm config set proxy=http://...
# npm config set http-proxy=http://...
# npm config set https-proxy=http://...
```

##### 1. Download Source
```
git clone https://github.com/apache/incubator-zeppelin.git
cd incubator-zeppelin
```

##### 2. Build
install dependency for zeppelin-web
```
cd zeppelin-web
npm install
```

config bower
```
npm install -g bower-canary
git config --global url."https://".insteadOf git://

http-proxy=http://...
https-proxy=http://...
```

build zeppelin
```
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"
mvn clean package install \
-Pspark-1.3 \
-Dhadoop.version=2.5.0-cdh5.2.0 \
-Dprotobuf.version=2.5.0 \
-Pyarn \
-DskipTests
```

##### 3. Configure
edit conf/zeppelin-evn.sh
```
export HADOOP_CONF_DIR=/etc/hadoop/conf
```

##### 4. Run
```
./bin/zeppelin-daemon.sh
./bin/zeppelin.sh
```

##### 5. Use
```
http://localhost:8080
```

### Architecutre

![](http://zeppelin.incubator.apache.org/assets/themes/zeppelin/img/interpreter.png)

```
25065 org.apache.zeppelin.interpreter.remote.RemoteInterpreterServer 30614 -Dspark.jars=/zeppelin/hadoop-lzo.jar -Dfile.encoding=UTF-8 -Xmx1024m -XX:MaxPermSize=512m -Dspark.jars=/zeppelin/hadoop-lzo.jar -Dfile.encoding=UTF-8 -Xmx1024m -XX:MaxPermSize=512m -Dzeppelin.log.file=/zeppelin/incubator-zeppelin/logs/zeppelin-interpreter-spark-root-Jupiter-spark-dev001-shjj.qiyi.virtual.log

5252 org.apache.zeppelin.interpreter.remote.RemoteInterpreterServer 40448 -Dspark.jars=/zeppelin/hadoop-lzo.jar -Dfile.encoding=UTF-8 -Xmx1024m -XX:MaxPermSize=512m -Dspark.jars=/zeppelin/hadoop-lzo.jar -Dfile.encoding=UTF-8 -Xmx1024m -XX:MaxPermSize=512m -Dzeppelin.log.file=/zeppelin/incubator-zeppelin/logs/zeppelin-interpreter-md-root-Jupiter-spark-dev001-shjj.qiyi.virtual.log
```
