# Spark Configuration

## Core
spark.driver.host=xxx.xxx.xxx.xxx
spark.io.compression.codec=org.apache.spark.io.LZFCompressionCodec
spark.serializer=org.apache.spark.serializer.KryoSerializer

## JVM
spark.driver.extraJavaOptions=-XX:MaxPermSize=256m
spark.executor.extraJavaOptions=-XX:MaxPermSize=256m

## Yarn
spark.yarn.maxAppAttempts=1
spark.yarn.executor.memoryOverhead=2048

## Log
spark.eventLog.enabled=true
spark.eventLog.dir=hdfs:///tmp/spark/logs

## Straming
### Kafka Direct
spark.streaming.backpressure.enabled=true
spark.streaming.kafka.maxRatePerPartition=100000

### Kafka Receiver
spark.streaming.receiver.maxRate=100000

## Others
spark.cleaner.ttl=21600
