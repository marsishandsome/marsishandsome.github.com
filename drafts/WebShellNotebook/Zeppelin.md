# Zeppelin
- [官网](https://zeppelin.incubator.apache.org/)
- [Introduction to Zeppelin](http://events.linuxfoundation.org/sites/events/files/slides/Zeppelin_ApacheCon2015_0.pdf)
- [Apache Zeppelin安装及介绍](http://blog.csdn.net/pelick/article/details/45934993)
- [Github](https://github.com/apache/incubator-zeppelin)
- [User Guide](http://zeppelin.incubator.apache.org/docs/index.html)
- [Install](http://zeppelin.incubator.apache.org/docs/install/install.html)

# Install
### 0. Prepare
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

### 1. Download Source
```
git clone https://github.com/apache/incubator-zeppelin.git
cd incubator-zeppelin
```

### 2. Build
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
mvn clean package \
-Pspark-1.3.0 \
-Dhadoop.version=2.5.0-cdh5.2.0 \
-Dprotobuf.version=2.5.0 \
-Pyarn \
-DskipTests
```

### 3. Configure
edit conf/zeppelin-evn.sh
```
export HADOOP_CONF_DIR=/etc/hadoop/conf
```

### 4. Run
```
./bin/zeppelin-daemon.sh
./bin/zeppelin.sh
```