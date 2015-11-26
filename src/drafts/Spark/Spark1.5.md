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

### SPARK-7937: Support ordering on StructType

## Spark1.5.1


## Spark1.5.2


## References
- [Spark1.5.0 Release Notes](http://spark.apache.org/releases/spark-release-1-5-0.html)
- [Spark1.5.1 Release Notes](http://spark.apache.org/releases/spark-release-1-5-1.html)
- [Spark1.5.2 Release Notes](http://spark.apache.org/releases/spark-release-1-5-2.html)
