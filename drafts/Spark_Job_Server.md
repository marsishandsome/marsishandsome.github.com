#Spark Job Server

### Zoomdata
- [Spark Summit](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-14-Zoomdata-Alarcon.pdf)

![](/images/spark_job_server_arch.png)

![](/images/spark_job_server_remoting.png)

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
- [Github New](https://github.com/spark-jobserver/spark-jobserver)
- [Github Old](http://github.com/ooyala/spark-jobserver)

1. "Spark as a Service": Simple REST interface for all aspects of job, context management
2. Support for Spark SQL Contexts/jobs and custom job contexts, Works for Spark Streaming as well!
3. Supports sub-second low-latency jobs via long-running job contexts
4. Start and stop job contexts for RDD sharing and low-latency jobs; change resources on restart
5. Kill running jobs via stop context
6. Separate jar uploading step for faster job startup
7. Asynchronous and synchronous job API. Synchronous API is great for low latency jobs!
8. Works with Standalone Spark as well as Mesos and yarn-client
9. Job and jar info is persisted via a pluggable DAO interface
10. Named RDDs to cache and retrieve RDDs by name, improving RDD sharing and reuse among jobs.
11. Jars, job history and config are persisted via a pluggable API
12. Async and sync API, JSON job results


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

sbt assembly -> fat jar -> upload to job server
```
curl --data-binary @job-server-tests/target/job-server-tests-$VER.jar localhost:8090/jars/test
OK
```

Ad-hoc Mode - Single, Unrelated Jobs (Transient Context)
```
curl -d "input.string = a b c a b see" 'localhost:8090/jobs?appName=test&classPath=spark.jobserver.WordCountExample'
{
  "status": "STARTED",
  "result": {
    "jobId": "5453779a-f004-45fc-a11d-a39dae0f9bf4",
    "context": "b7ea0eb5-spark.jobserver.WordCountExample"
  }
}

curl localhost:8090/jobs/5453779a-f004-45fc-a11d-a39dae0f9bf4
{
  "status": "OK",
  "result": {
    "a": 2,
    "b": 2,
    "c": 1,
    "see": 1
  }
}
```

Persistent Context Mode - Faster & Required for Related Jobs
```
curl -d "" 'localhost:8090/contexts/test-context?num-cpu-cores=4&memory-per-node=512m'
OK

curl localhost:8090/contexts
["test-context"]

curl -d "input.string = a b c a b see" 'localhost:8090/jobs?appName=test&classPath=spark.jobserver.WordCountExample&context=test-context&sync=true'
{
  "status": "OK",
  "result": {
    "a": 2,
    "b": 2,
    "c": 1,
    "see": 1
  }
}
```


### Spark-Admin -- provides administrators and developers a GUI to provision and manage Spark clusters easily
- [github](https://github.com/adatao/adatao-admin)


### 二进制兼容问题
- Reading from HDFS
- Spark driver’s hadoop libraries need to match those on the spark cluster
- We made these libraries configurable by:
- Decoupling the spark driver into a separate process
- Allowing administrators to configure what libraries through a UI
- Kicking off a spark driver process with the configured hadoop libraries


