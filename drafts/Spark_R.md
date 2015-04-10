# Spark R
SparkR项目最近已经merge到spark的master分支，将会在spark-1.4.0中正式发布。SparkR项目的意义在于：
- 使用R语言的专业人士可以无缝地通过R语言来使用Spark
- 在Spark上可以使用R的上千个package，避免重复发明轮子
- 证明了Spark框架的可扩展性

本篇主要来分析一下SparkR的架构。


### Arcitecutre


![](/images/spark_r_dataflow.png)

![](/images/spark_r_how_work.png)



### Links
- [SparkR 官网](http://amplab-extras.github.io/SparkR-pkg/)
- [SparkR Github](https://github.com/amplab-extras/SparkR-pkg)
- [SparkR Apache JIRA](https://issues.apache.org/jira/browse/SPARK-5654)
- [SparkR Github Pull Request](https://github.com/apache/spark/pull/5096)


### Documents
- [SparkR: Interactive R programs at Scale](http://spark-summit.org/2014/talk/sparkr-interactive-r-programs-at-scale-2) - Spark Summit 2014
- [SparkR Enabling Interactive Data Science at Scale on Hadoop](https://www.youtube.com/watch?v=Y21t3Taw7i8) - Hadoop Summit
- [AMP Camp 5: SparkR](https://www.youtube.com/watch?v=OxVIns6zvlk)


### Details
- [解惑rJava R与Java的高速通道](http://blog.fens.me/r-rjava-java/)
- [How R Searches and Finds Stuff](http://blog.obeautifulcode.com/R/How-R-Searches-And-Finds-Stuff/)

