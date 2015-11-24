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

### [Type safe api reference](https://github.com/twitter/scalding/wiki/Type-safe-api-reference)
TODO

### [PCollection](https://cloud.google.com/dataflow/model/pcollection)
TODO

## Automatic memory configuration
- [SPARK-10000](https://issues.apache.org/jira/browse/SPARK-10000)
- [Design Doc](https://issues.apache.org/jira/secure/attachment/12765646/unified-memory-management-spark-10000.pdf)

Old Design
- Execution spark.shuffle.memoryFraction (default=0.2)
- Storage spark.storage.memoryFraction (default=0.6)
- Other (default=0.2)

New Design
- spark.memory.fraction (default=0.75)
- spark.memory.storageFraction (default=0.5)

TODO


## Optimized state storage in Spark Streaming
- [SPARK-2629](https://issues.apache.org/jira/browse/SPARK-2629)
- [Design Doc](https://docs.google.com/document/d/1NoALLyd83zGs1hNGMm0Pc5YOVgiPpMHugGMk6COqxxE/edit#heading=h.ph3w0clkd4em)
- [Prototype](https://github.com/apache/spark/pull/9256)

TODO

## Pipeline persistence in Spark ML
- [SPARK-6725](https://issues.apache.org/jira/browse/SPARK-6725)
- [Design Doc](https://docs.google.com/document/d/1RleM4QiKwdfZZHf0_G6FBNaF7_koc1Ui7qfMT1pf4IA/edit)

TODO

## [Spark 1.6.0 Preview](https://docs.cloud.databricks.com/docs/spark/1.6/index.html#00%20Spark%201.6%20Preview.html)
TODO
