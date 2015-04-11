# Spark R 架构分析
SparkR项目最近已经merge到spark的master分支，将会在spark-1.4.0中正式发布。

我认为SparkR项目的意义在于：

1. 使用R语言的专业人士可以无缝地通过R语言来使用Spark
2. 在Spark上可以使用R的上千个package，避免重复发明轮子
3. 证明了Spark框架的可扩展性

本篇主要来分析一下SparkR的架构。


### Arcitecutre
SparkR的架构类似于PySpark，Driver端除了一个JVM进程（包含一个SparkContext）外，还有起一个R的进程，这两个进程通过Socket进行通信，用户可以提交R语言代码，R的进程会执行这些R代码，当R代码调用Spark相关函数时，R进程会通过Socket触发JVM中的对应任务。

当R进程向JVM进程提交任务的时候，R会把子任务需要的环境(enclosing environment)进行打包，并发送到JVM的driver端。

通过R生成的RDD都会是RRDD类型，当触发RRDD的action时，Spark的执行器会开启一个R进程(worker.R)，执行器和R进程通过Socket进行通信。执行器会把任务和所需的环境发送给R进程，R进程会加载对应的package，执行任务，并返回结果。

<img src="/images/spark_r_dataflow.png" width="1000px">


下面是介绍一些执行SparkR的详细流程：

1. SparkSubmit判断是SparkR类型的任务，启动RRunner
2. RRunner首先启动RBackend，然后再启动R进程执行用户的R脚本
3. RBackend开启Socket Server，等待R进程链接
4. R进程通过Socket连接到RBackend
5. R脚本生成SparkContext，通过Socket通信，会在JVM中生成JavaSparkContext
6. R脚本触发RRDD的action，通过Socket通信，Driver启动executor，并执行对于的任务
7. 在每个执行器中都会调用RRDD的compute函数，来计算RRDD中的数据
8. compute函数首先开启Socket Server，等待R进程链接，然后启动一个R进程(worker.R)
9. R进程通过Socket链接到执行器，读取执行器发送过来的任务，执行任务，并返回结果
10. compute函数读取R进程发来的结果数据，并返回iterator


1-6属于driver端，7-10属于executor端。

<img src="/images/spark_r_workflow.png" width="1000px">


### 可能的问题及改进
1. Standalone模式如何控制R进程的资源？
2. JVM进程和R进程通过Socket进行通信，代价多高？可否用共享内存？


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
- [How R Searches and Finds Stuff](http://blog.obeautifulcode.com/R/How-R-Searches-And-Finds-Stuff/)

