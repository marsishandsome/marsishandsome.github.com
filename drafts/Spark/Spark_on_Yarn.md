# Spark on Yarn

### Links for Yarn
- [YARN应用开发流程](http://my.oschina.net/u/1434348/blog/193374)


### Links for Spark on Yarn
- [spark on yarn的技术挑战](http://dongxicheng.org/framework-on-yarn/spark-on-yarn-challenge/) - 董的博客
- [Spark on Yarn: a deep dive](http://www.chinastor.org/upload/2014-07/14070710043699.pdf) - Sandy Ryza @Cloudera
- [Apache Spark Resource Management and YARN App Models](http://blog.cloudera.com/blog/2014/05/apache-spark-resource-management-and-yarn-app-models/)
- [Apache Spark源码走读之8 -- Spark on Yarn](http://www.cnblogs.com/hseagle/p/3728713.html)


### Data Locality
使用preferredNodeLocationData

    val locData = InputFormatInfo.computePreferredLocations(
      Seq(new InputFormatInfo(conf, classOf[TextInputFormat], new Path("hdfs:///myfile.txt")))
    val sc = new SparkContext(conf, locData)


### Problems
1. Spark无法动态增加/减少资源，Container-Resizing [YARN-1197](https://issues.apache.org/jira/browse/YARN-1197)
2. [Timeline Store YARN-321](https://issues.apache.org/jira/browse/YARN-321)

