# Spark Profiling

### Java Profiling

[常用 Java Profiling 工具的分析与比较](http://www.ibm.com/developerworks/cn/java/j-lo-profiling/)

- 事件方法：对于 Java，可以采用 JVMTI（JVM Tools Interface）API 来捕捉诸如方法调用、类载入、类卸载、进入 / 离开线程等事件，然后基于这些事件进行程序行为的分析。
- 统计抽样方法（sampling）: 该方法每隔一段时间调用系统中断，然后收集当前的调用栈（call stack）信息，记录调用栈中出现的函数及这些函数的调用结构，基于这些信息得到函数的调用关系图及每个函数的 CPU 使用信息。由于调用栈的信息是每隔一段时间来获取的，因此不是非常精确的，但由于该方法对目标程序的干涉比较少，目标程序的运行速度几乎不受影响。
- 植入附加指令方法（BCI）: 该方法在目标程序中插入指令代码，这些指令代码将记录 profiling 所需的信息，包括运行时间、计数器的值等，从而给出一个较为精确的内存使用情况、函数调用关系及函数的 CPU 使用信息。该方法对程序执行速度会有一定的影响，因此给出的程序执行时间有可能不准确。但是该方法在统计程序的运行轨迹方面有一定的优势。

[9 个帮助你进行Java性能调优的工具](http://www.open-open.com/news/view/1ec20f6)


# Java调优
- [Java SE 6 HotSpot[tm] Virtual Machine Garbage Collection Tuning](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html)
- [Everything I Ever Learned about JVM Performance Tuning](http://www.infoq.com/presentations/JVM-Performance-Tuning-twitter)
- [java profiling heapster](https://github.com/mariusae/heapster) - Production heap profiling for the JVM
- [java profiling jvmgcprof](https://github.com/twitter/jvmgcprof) - A simple utility for profile allocation and garbage collection activity in the JVM


### VisualVM 
- 在服务器端起一个监控程序
- [官网](http://visualvm.java.net/)
- [使用 VisualVM 进行性能分析及调优](http://www.ibm.com/developerworks/cn/java/j-lo-visualvm/)
- [visualvm监控jvm及远程jvm监控方法](http://www.blogjava.net/titanaly/archive/2012/03/20/372318.html)

### YourKit 
- 增加 -agentpath:<full agent library path> VM 选项到java 命令行启动参数
- 商业软件
- [官网](https://www.yourkit.com/overview/)
- [yourkit性能监控工具，远程监控](http://zhwj184.iteye.com/blog/764575)

### Profiler4j 
- java -javaagent:c:\profiler4j-1.0-beta2\agent.jar com.foo.Main
- 开源软件
- [官网](http://profiler4j.sourceforge.net/)

### Spark
- spark.python.profile
- spark.python.profile.dump
- [Profiling Spark Applications Using YourKit](https://cwiki.apache.org/confluence/display/SPARK/Profiling+Spark+Applications+Using+YourKit)

### 论文
- [JaViz: A client/server Java profiling tool](http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=5387066&url=http%3A%2F%2Fieeexplore.ieee.org%2Fxpls%2Fabs_all.jsp%3Farnumber%3D5387066)


### statsd-jvm-profiler
- [Github](https://github.com/etsy/statsd-jvm-profiler)
- [Introducing statsd-jvm-profiler: A JVM Profiler for Hadoop](https://codeascraft.com/2015/01/14/introducing-statsd-jvm-profiler-a-jvm-profiler-for-hadoop/)

### StatsD
- [Github](https://github.com/etsy/statsd)
- [Understanding StatsD and Graphite](https://blog.pkhamre.com/understanding-statsd-and-graphite/)
- [How To Configure StatsD to Collect Arbitrary Stats for Graphite](https://www.digitalocean.com/community/tutorials/how-to-configure-statsd-to-collect-arbitrary-stats-for-graphite-on-ubuntu-14-04)

### Flame
- [Github](https://github.com/brendangregg/FlameGraph)
- [Flame Graphs](http://www.brendangregg.com/flamegraphs.html)

### Graphite
- [HTTP API](https://github.com/brutasse/graphite-api/blob/master/docs/api.rst)


### Others
[Simz](http://www.autoletics.com/)

