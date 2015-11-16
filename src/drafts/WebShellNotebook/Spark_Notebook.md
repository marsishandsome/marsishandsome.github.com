# Spark Notebook
- [官网](http://spark-notebook.io/)
- [Github](https://github.com/andypetrella/spark-notebook)

```
sbt -D"spark.version"="1.5.1" -D"hadoop.version"="2.5.0-cdh5.2.0"
```

```
play.core.server.NettyServer \
-Duser.dir=/data/spark-notebook/spark-notebook-0.6.2

notebook.kernel.pfork.ChildProcessMain \
notebook.kernel.remote.RemoteActorProcess \
45043 \
info \
46e79dab-5b52-48c3-b682-2b92b21e6a88 \
"core/test yarn.snb" \
kernel  \
-Xmx1782054912 \
-XX:MaxPermSize=1073741824

notebook.kernel.pfork.ChildProcessMain \
notebook.kernel.remote.RemoteActorProcess \
46227 \
info \
47b1d57f-2c63-48ca-a131-0295f54ac44b \
"core/Simple Spark.snb" \
kernel  \
-Xmx1782054912 \
-XX:MaxPermSize=1073741824


/usr/java/jdk1.7.0_67/jre/bin/java -Xmx1782054912 -XX:MaxPermSize=1073741824 \
-server notebook.kernel.pfork.ChildProcessMain \
notebook.kernel.remote.RemoteActorProcess 63999 info 9bfd0d39-e972-4552-b9cc-88e0524a58f2 "core/Simple Spark.snb" kernel
```
