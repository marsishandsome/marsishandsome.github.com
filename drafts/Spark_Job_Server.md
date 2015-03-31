#Spark Job Server

### Zoomdata
- [Spark Summit](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-14-Zoomdata-Alarcon.pdf)

![](/images/spark_job_server_arch.png)

![](spark_job_server_remoting.png)

1. Fine grained configuration of Spark Context
2. Progress Reporting
3. Custom Parsers of Raw Values JdbcRdd.convertValue
4. TSV support
5. XML support
6. YARN support
7. Spark programming model
8. load and read requests in separate scheduler’s pools
9. Cancel queries


### HiveThriftServer


### Spark Job Server
- [Spark Summit](http://spark-summit.org/wp-content/uploads/2014/07/Spark-Job-Server-Easy-Spark-Job-Management-Chan-Chu.pdf)
- [Github](http://github.com/ooyala/spark-jobserver)

1. REST API for Spark jobs and contexts. Easily operate Spark from any language or environment.
2. Runs jobs in their own Contexts or share 1 context amongst jobs
3. Great for sharing cached RDDs across jobs and low-latency jobs
4. Works for Spark Streaming as well!
5. Works with Standalone, Mesos, any Spark config
6. Jars, job history and config are persisted via a pluggable API
7. Async and sync API, JSON job results

sbt assembly -> fat jar -> upload to job server

```
/**
* A super-simple Spark job example that implements the SparkJob trait and
* can be submitted to the job server.
*/
object WordCountExample extends SparkJob {
override def validate(sc: SparkContext, config: Config): SparkJobValidation = {
 Try(config.getString(“input.string”))
 .map(x => SparkJobValid)
 .getOrElse(SparkJobInvalid(“No input.string”))
 }
override def runJob(sc: SparkContext, config: Config): Any = {
 val dd = sc.parallelize(config.getString(“input.string”).split(" ").toSeq)
 dd.map((_, 1)).reduceByKey(_ + _).collect().toMap
 }
}
```

- Job does not create Context, Job Server does 
- Decide when I run the job: in own context, or in pre-created context
- Upload new jobs to diagnose your RDD issues:
  - POST /contexts/newContext
  - POST /jobs .... context=newContext
  - Upload a new diagnostic jar... POST /jars/newDiag
  - Run diagnostic jar to dump into on cached RDDs

```
curl --data-binary @../target/mydemo.jar localhost:8090/jars/demo
OK[11:32 PM] ~
curl -d "input.string = A lazy dog jumped mean dog" 'localhost:8090/jobs?
appName=demo&classPath=WordCountExample&sync=true'
{
 "status": "OK",
 "RESULT": {
 "lazy": 1,
 "jumped": 1,
 "A": 1,
 "mean": 1,
 "dog": 2
 }
```


### 二进制兼容问题
- Reading from HDFS
- Spark driver’s hadoop libraries need to match those on the spark cluster
- We made these libraries configurable by:
- Decoupling the spark driver into a separate process
- Allowing administrators to configure what libraries through a UI
- Kicking off a spark driver process with the configured hadoop libraries


