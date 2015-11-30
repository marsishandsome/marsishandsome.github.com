# Spark1.5

## Spark1.5.0

### New experimental user-defined aggregate function (UDAF) interface
- [SPARK-3947](https://issues.apache.org/jira/browse/SPARK-3947)

在SparkSQL中支持用户自定义的聚合函数，先register聚合函数，再在sql语句中调用。
```
class GeometricMean extends UserDefinedAggregateFunction {...}
sqlContext.udf.register("gm", new GeometricMean)
sqlContext.sql("""select gm(filedName) from tableName""");
```

### DataFrame hint for broadcast join
- [SPARK_8300](https://issues.apache.org/jira/browse/SPARK-8300)

根据表的大小是否小于```spark.sql.autoBroadcastJoinThreshold```，Spark会自动判断是否需要使用broadcast join，
新的语法可以让用户直接提示执行器使用broadcast join。
```
left.join(broadcast(right), "joinKey")
```

### Memory and local disk only checkpointing support
- [SPARK-1855](https://issues.apache.org/jira/browse/SPARK-1855)
- [Design Doc](https://issues.apache.org/jira/secure/attachment/12741708/SPARK-7292-design.pdf)
- [Patch](https://github.com/apache/spark/pull/7279/files)

```rdd.checkpoint()```是基于DFS实现的，RDD的数据将会复制3份保持到硬盘，为了提高checkpoint的效率，
Spark提供了```rdd.localCheckpoint()```，Executor会把RDD的数据保持一份到本地磁盘，
提高了checkpoint的效率，但是当某个Executor挂掉时，该份数据将被重算。

### Dynamic allocation in YARN works with preferred locations
- [SPARK-4352](https://issues.apache.org/jira/browse/SPARK-4352)
- [Design Doc](https://issues.apache.org/jira/secure/attachment/12735126/Supportpreferrednodelocationindynamicallocation.pdf)
- [Patch](https://github.com/apache/spark/pull/6394/files)

Spark会记录所有Pending Task的数据依赖，在向Yarn申请资源的时候，会尽量申请靠近数据的执行器。

### Dynamic resource allocation support
TODO

## Spark1.5.1


## Spark1.5.2


## References
- [Spark1.5.0 Release Notes](http://spark.apache.org/releases/spark-release-1-5-0.html)
- [Spark1.5.1 Release Notes](http://spark.apache.org/releases/spark-release-1-5-1.html)
- [Spark1.5.2 Release Notes](http://spark.apache.org/releases/spark-release-1-5-2.html)
