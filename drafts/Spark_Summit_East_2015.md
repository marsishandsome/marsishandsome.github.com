# SPARK SUMMIT EAST 2015

### New Directions for Spark in 2015 
- Matei Zaharia (CTO, Databricks)
- [slide](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-1-Matei-Zaharia.pdf)

##### 2014
- DataFrame API
- Machine Learning Piplines
- SparkR 1.4

##### 2015
- Data Science -- High-level interfaces similar to single-machine tools
- Platform Interfaces -- Plug in data sources and algorithms 

##### Goal
unified engine across data sources, workloads and environments 


### Embracing Spark as the Scalable Data Analytics Platform for the Enterprise
- Matthew Glickman (Managing Director, Goldman Sachs)
- [slide](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-4-Matthew-Glickman.pdf)
- Don’t wrap Spark
- Think of Spark Client API like ODBC/JDBC
- using existing JVM IDE environment instead of spark-submit for easier debugging
- Dynamically deploy code to cluster at run-time with lambda closures 
```
val sc = new SparkContext(conf)
sc.addJar(JarCreator.createJarFile(JarCreator.getClassesFromClassPath(getClass.getPackage.getName)))
```


### Spark User Concurrency and Context/RDD Sharing at Production Scale 
- Farzad Aref (Zoomdata), Justin Langseth (Zoomdata)
- [slide](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-14-Zoomdata-Alarcon.pdf)
- 类似于Spark Job Server, Hive Thrift Server


### Power Hive with Spark 
- Chao Sun (Cloudera), Marcelo Vanzin (Cloudera)
- [slide](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-17-Marcelo-Vanzin-Chao-Sun.pdf)

##### Dynamic Executor Allocation 

##### Remote Spark Context
- SparkContext uses non-trivial amount of memory
- Spark doesn’t support multiple SparkContexts
- `new SparkContext()` doesn’t support cluster mode
- Need to isolate user’s sessions
- Need to account for user’s resource usage 

- Solution: allow HS2 to start Spark apps out-of-process and interact with them.

### Developer Using Spark and Elasticsearch for real-time data analysis 
- Costin Leau (Elasticsearch)  
- [slide](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-35-Leau.pdf)

### Towards Modularizing Spark Machine Learning Jobs 
- Lance Co Ting Keh (Box) 
- [slide](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-29-Lance-Co-Ting-Keh.pdf)

##### Sparkle 
- Type Save

