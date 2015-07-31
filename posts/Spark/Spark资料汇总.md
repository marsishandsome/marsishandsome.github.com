# Spark资料汇总
Spark部分资料可在[百度云下载](http://pan.baidu.com/s/1ntswMqH#path=%252F%25E5%2585%25B1%25E4%25BA%25AB%25E8%25B5%2584%25E6%2596%2599%252FSpark)

### Spark论文
##### Spark Core
- [Spark: Cluster Computing with Working Sets](http://people.csail.mit.edu/matei/papers/2010/hotcloud_spark.pdf)
- [Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing](http://www.cs.berkeley.edu/~matei/papers/2012/nsdi_spark.pdf)
- [Spark Matei PHD 论文翻译版](https://code.csdn.net/CODE_Translation/spark_matei_phd)

##### Spark SQL
- [Shark: SQL and Rich Analytics at Scale](http://www.eecs.berkeley.edu/Pubs/TechRpts/2012/EECS-2012-214.pdf)
- [Spark SQL: Relational Data Processing in Spark](http://people.csail.mit.edu/matei/papers/2015/sigmod_spark_sql.pdf)

##### Spark Streaming
- [Discretized Streams: An Efficient and Fault-Tolerant Model for Stream Processing on Large Clusters](http://www.cs.berkeley.edu/~matei/papers/2012/hotcloud_spark_streaming.pdf)
- [The 8 Requirements of Real-Time Stream Processing](http://cs.brown.edu/~ugur/8rulesSigRec.pdf)


### Spark入门
- [Spark Hands-on Exercises](http://ampcamp.berkeley.edu/big-data-mini-course/index.html) - Spark交互式练习
- [AMPLab Hands-on Exercises](http://ampcamp.berkeley.edu/5/exercises/index.html) [Video](http://pan.baidu.com/s/1kTIdlMv#path=%252F) - Spark Tachyon交互式练习
- [Apache Spark API By Example](http://homepage.cs.latrobe.edu.au/zhe/files/SparkAPIMaster.pdf) - Spark API


### Spark深入研究
- [Spark Internals](https://github.com/JerryLead/SparkInternals/blob/master/markdown/0-Introduction.md) - Spark设计思想、运行原理、实现架构及性能调优
- [许鹏：从零开始学习，Apache Spark源码走读](http://www.csdn.net/article/2014-05-29/2820013) - Spark源码解读


### Spark博客
- [Databricks Blog](http://databricks.com/blog)
- [mmicky的hadoop、Spark世界](http://blog.csdn.net/book_mmicky) - SparkCore, SparkSQL分析
- [徽沪一郎](http://www.cnblogs.com/hseagle/) - Spark Common使用
- [OopsOutOfMemory](http://blog.csdn.net/oopsoom) - Spark分析
- [赛赛的网络日志 Jerry Shao](http://jerryshao.me/) - Spark内部实现
- [baishuo491](http://baishuo491.iteye.com/blog) - Spark源码
- [CSDN专栏](http://spark.csdn.net/)


### Spark文章
- [有什么关于 Spark 的书推荐？](http://www.zhihu.com/question/23655827/answer/29611595) -- 知乎
- [Spark核心开发者：性能超Hadoop百倍，算法实现仅有其1/10或1/100](http://www.csdn.net/article/2013-04-26/2815057-Spark-Reynold)
- [浅谈Apache Spark的6个发光点](http://www.csdn.net/article/2014-08-07/2821098-6-sparkling-feat)
- [Spark: Open Source Superstar Rewrites Future of Big Data](http://www.wired.com/2013/06/yahoo-amazon-amplab-spark/all/)
- [Spark is a really big deal for big data, and Cloudera gets it](https://gigaom.com/2013/10/28/spark-is-a-really-big-deal-for-big-data-and-cloudera-gets-it/)
- [盘点SQL on Hadoop中用到的主要技术](http://sunyi514.github.io/2014/11/15/%E7%9B%98%E7%82%B9sql-on-hadoop%E4%B8%AD%E7%94%A8%E5%88%B0%E7%9A%84%E4%B8%BB%E8%A6%81%E6%8A%80%E6%9C%AF/)
- [梳理对Spark Standalone的理解](http://blog.csdn.net/pelick/article/details/43762375)
- [Improving Sort Performance in Apache Spark: It’s a Double](http://blog.cloudera.com/blog/2015/01/improving-sort-performance-in-apache-spark-its-a-double/)
- [Tutorial: Spark-GPU Cluster Dev in a Notebook](http://iamtrask.github.io/2014/11/22/spark-gpu/)
- [Databricks Spark Knowledge Base](https://www.gitbook.com/book/databricks/databricks-spark-knowledge-base/details)
- [连城：大数据场景下的“搔到痒处”和“戳到痛处”（图灵访谈）](http://www.ituring.com.cn/article/179495)
- [Spark技术解析及在百度开放云BMR应用实践](http://mp.weixin.qq.com/s?__biz=MjM5OTY0ODg1Mw==&mid=203928894&idx=1&sn=f6e6e3ffb72d7ab51372f43904ec1c1c&scene=1&from=groupmessage&isappinstalled=0#rd)
- [一个KCore算法引发的StackOverflow奇案](http://rdc.taobao.org/?p=2417&amp;amp;from=groupmessage&amp;amp;isappinstalled=0)


### Spark调优
- [Tuning Spark](http://spark.apache.org/docs/latest/tuning.html) - 官网资料
- [Advanced Spark Internals and Tuning](https://www.youtube.com/watch?v=HG2Yd-3r4-M) - Reynold Xin @ Spark summit 2014
- [Everyday I am Shuffling - Tips for Writing Better Spark Programs](https://www.youtube.com/watch?v=Wg2boMqLjCg) - Holen Karau @ Strata San Jose 2015
- [How-to: Tune Your Apache Spark Jobs (Part 1)](http://blog.cloudera.com/blog/2015/03/how-to-tune-your-apache-spark-jobs-part-1/) - Cloudera
- [How-to: Tune Your Apache Spark Jobs (Part 2)](http://blog.cloudera.com/blog/2015/03/how-to-tune-your-apache-spark-jobs-part-2/) - Cloudera
- [Tuning Spark Streaming for Throughput](http://www.virdata.com/tuning-spark/)
- [Tuning Java Garbage Collection for Spark Applications](https://databricks.com/blog/2015/05/28/tuning-java-garbage-collection-for-spark-applications.html)
- [executor-cores vs. num-executors](http://apache-spark-user-list.1001560.n3.nabble.com/executor-cores-vs-num-executors-td9878.html)


### Spark Meetup
[百度云下载地址](http://pan.baidu.com/s/1ntswMqH#path=%252F%25E5%2585%25B1%25E4%25BA%25AB%25E8%25B5%2584%25E6%2596%2599%252FSpark%252FMeetup%2526Summit)

- [Spark Summit](http://spark-summit.org/)
- [Spark Users Meetup](http://www.meetup.com/spark-users/)
- [北京 Spark Meetup](http://www.meetup.com/spark-user-beijing-Meetup/)
- [上海 Spark Meetup](http://www.meetup.com/Shanghai-Apache-Spark-Meetup/)
- [杭州 Spark Meetup](http://www.meetup.com/Hangzhou-Apache-Spark-Meetup/)


### Spark参与者
##### Ion Stoica
- Berkeley教授，AMPLab 领军
- [Home Page](http://www.cs.berkeley.edu/~istoica/)

##### Matei Zaharia
- Co-founder and CTO of Databricks
- [Wikipedia](http://en.wikipedia.org/wiki/Matei_Zaharia)
- [Home Page](http://people.csail.mit.edu/matei/)
- [Github](https://github.com/mateiz)

##### Reynold Xin (hashjoin)
- Apache Spark开源社区的主导人物之一。他在UC Berkeley AMPLab进行博士学业期间参与了Spark的开发，并在Spark之上编写了Shark和GraphX两个开源框架。他和AMPLab同僚共同创建了Databricks公司。

- [Github](https://github.com/rxin)
- [新浪微博 @hashjoin](http://www.weibo.com/hashjoin)
- [伯克利主页](http://www.cs.berkeley.edu/~rxin/)
- [Github IO 资料](https://rxin.github.io/)

##### Holden Karau
- Senior Software Development Engineer @ Databricks
- [Resume](http://www.holdenkarau.com/resume.pdf?q=github)
- [Github](https://github.com/holdenk)
- [Book: Fast Data Processing with spark](http://it-ebooks.info/book/3185/)
- [Book: Learning Spark](http://shop.oreilly.com/product/0636920028512.do)

##### 连城
- Databricks software engineer, Apache Spark contributor
- [新浪微博 @连城404](http://www.weibo.com/lianchengzju)
- [个人主页](http://blog.liancheng.info/)

##### 陈超
- Apache Spark Contributor, Spark meetup(Hangzhou) 发起人
- [新浪微博 @CrazyJvm](http://www.weibo.com/476691290)

##### JerryLead (Lijie Xu)
- A Ph.D student in ISCAS 中国科学院软件学院
- [新浪微博 @JerryLead](http://www.weibo.com/jerrylead)
- [Github IO](http://jerrylead.github.io/)
- [Github](https://github.com/JerryLead)
- [JerryLead博客园](http://www.cnblogs.com/jerrylead/default.html?page=1)
- [Spark Internals by JerryLead](https://github.com/JerryLead/SparkInternals/blob/master/markdown/0-Introduction.md)

##### JasonDai
- 英特尔大数据首席架构师，Apache Spark项目Committer及PMC成员
- [新浪微博 @JasonDai英特尔](http://www.weibo.com/u/3816918426)

##### 张包峰
- [新浪微博 @张包峰](http://www.weibo.com/pelickzhang)
- [张包峰的博客](http://blog.csdn.net/pelick)

##### 王家林
- Spark亚太研究院院长和首席专家
- [Spark亚太研究院决胜大数据时代100期公益大讲堂](http://edu.51cto.com/course/course_id-1659.html)
- [百度云资料](http://pan.baidu.com/share/home?uk=4013289088#category/type=0)
