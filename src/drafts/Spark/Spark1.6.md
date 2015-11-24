# Spark 1.6
- [Announcing Spark 1.6 Preview in Databricks](https://databricks.com/blog/2015/11/20/announcing-spark-1-6-preview-in-databricks.html)
- [Spark 1.6.0 Preview](https://docs.cloud.databricks.com/docs/spark/1.6/index.html#00%20Spark%201.6%20Preview.html)

## Dataset API
- [SPARK-9999](https://issues.apache.org/jira/browse/SPARK-9999)
- [Design Doc](https://docs.google.com/document/d/1ZVaDqOcLm2-NcS0TElmslHLsEIEwqzt0vBvzpLrV6Ik/edit#)
- [Prototype](https://github.com/marmbrus/spark/pull/18/files)

RDD API可以进行类型检查，但是不能使用Catalyst进行优化；
DataFrame API可以使用Catalyst进行优化，但是不能进行类型检查；
Dataset API介于两者之间，即可以进行类型检查又可以使用Catalyst进行优化。

```
// Dataset例子
val df = Seq((1, 2)).toDF("a", "b") // DataFrame
val ds = df.as[(Int, Int)]          // Dateset
ds.map {
  case (a, b) => (a, b, a + b)
}
```

### [Type safe api reference](https://github.com/twitter/scalding/wiki/Type-safe-api-reference)
TODO

### [PCollection](https://cloud.google.com/dataflow/model/pcollection)
TODO

## Automatic memory configuration
- [SPARK-10000](https://issues.apache.org/jira/browse/SPARK-10000)
- [Design Doc](https://issues.apache.org/jira/secure/attachment/12765646/unified-memory-management-spark-10000.pdf)

在Spark-1.5中，Spark的内存分为三个部分
1. 执行内存 spark.shuffle.memoryFraction (default=0.2)
2. 存储内存 spark.storage.memoryFraction (default=0.6)
3. 其他内存 (default=0.2)

这三部分内存是互相独立的，不能互相借用，这给使用者提出了很高的要求。
Spark-1.6中简化了内存配置，执行内存和存储内存可以互相借用，其中
1. spark.memory.fraction (default=0.75) 这部分内存用于执行和存储
2. spark.memory.storageFraction (default=0.5) 这部分内存是存储内存的最大值

## Optimized state storage in Spark Streaming
- [SPARK-2629](https://issues.apache.org/jira/browse/SPARK-2629)
- [Design Doc](https://docs.google.com/document/d/1NoALLyd83zGs1hNGMm0Pc5YOVgiPpMHugGMk6COqxxE/edit#heading=h.ph3w0clkd4em)
- [Prototype](https://github.com/apache/spark/pull/9256)

```updateStateByKey```存在以下问题
1. 没有delete key机制，随着数据增多，每个Batch的处理时间会增大
2. 没有Timeout机制

```trackStateByKey```试图解决这些问题，增加了delete key以及Timeout机制，用户可以更加灵活的使用有状态的Streaming。

TODO

## Pipeline persistence in Spark ML
- [SPARK-6725](https://issues.apache.org/jira/browse/SPARK-6725)
- [Design Doc](https://docs.google.com/document/d/1RleM4QiKwdfZZHf0_G6FBNaF7_koc1Ui7qfMT1pf4IA/edit)

Spark ML之前只能保存Module，1.6中新增可以保存Pipline，可用于
1. 重新运行workflow
2. 导出到外部的系统

## [Spark 1.6.0 Preview](https://docs.cloud.databricks.com/docs/spark/1.6/index.html#00%20Spark%201.6%20Preview.html)
TODO
