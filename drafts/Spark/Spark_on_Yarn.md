# Spark on Yarn


### Data Locality
使用preferredNodeLocationData

    val locData = InputFormatInfo.computePreferredLocations(
      Seq(new InputFormatInfo(conf, classOf[TextInputFormat], new Path("hdfs:///myfile.txt")))
    val sc = new SparkContext(conf, locData)


### 存在问题及改进
1. Spark无法动态增加/减少资源，Container-Resizing [YARN-1197](https://issues.apache.org/jira/browse/YARN-1197)
2. Timeline Store, [YARN-321](https://issues.apache.org/jira/browse/YARN-321)


### Links
- [spark on yarn的技术挑战](http://dongxicheng.org/framework-on-yarn/spark-on-yarn-challenge/) - 董的博客
- [Spark on Yarn: a deep dive](http://www.chinastor.org/upload/2014-07/14070710043699.pdf) - Sandy Ryza @Cloudera


