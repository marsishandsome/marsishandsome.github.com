# Spark IndexedRDD: Efficient Fine-Grained Updates for RDDs
[Ankur Dave](http://ankurdave.com/)
AMPLab – UC Berkeley

### 接口
```scala
class IndexedRDD[K: ClassTag, V: ClassTag] extends RDD[(K, V)] {

    /** Gets the values corresponding to the specified keys, if any. */
    def multiget(ks: Array[K]): Map[K, V]

    /**
       * Updates the keys in `kvs` to their corresponding values, running `merge` on old and new values
       * if necessary. Returns a new IndexedRDD that reflects the modification.
       */
    def multiput[U: ClassTag](kvs: Map[K, U], z: (K, U) => V, f: (K, V, U) => V): IndexedRDD[K, V]

    /**
      * Deletes the specified keys. Returns a new IndexedRDD that reflects the deletions.
      */
    def delete(ks: Array[K]): IndexedRDD[K, V]
}
```

```scala
object IndexedRDD {
  /**
   * Constructs an updatable IndexedRDD from an RDD of pairs, merging duplicate keys arbitrarily.
   */
  def apply[K: ClassTag : KeySerializer, V: ClassTag] (elems: RDD[(K, V)]): IndexedRDD[K, V]
}
```

### 使用

```scala
import edu.berkeley.cs.amplab.spark.indexedrdd.IndexedRDD

// Create an RDD of key-value pairs with Long keys.
val rdd = sc.parallelize((1 to 1000000).map(x => (x.toLong, 0)))
// Construct an IndexedRDD from the pairs, hash-partitioning and indexing
// the entries.
val indexed = IndexedRDD(rdd).cache()

// Perform a point update.
val indexed2 = indexed.put(1234L, 10873).cache()
// Perform a point lookup. Note that the original IndexedRDD remains
// unmodified.
indexed2.get(1234L) // => Some(10873)
indexed.get(1234L) // => Some(0)

// Efficiently join derived IndexedRDD with original.
val indexed3 = indexed.innerJoin(indexed2) { (id, a, b) => b }.filter(_._2 != 0)
indexed3.collect // => Array((1234L, 10873))

// Perform insertions and deletions.
val indexed4 = indexed2.put(-100L, 111).delete(Array(998L, 999L)).cache()
indexed2.get(-100L) // => None
indexed4.get(-100L) // => Some(111)
indexed2.get(999L) // => Some(0)
indexed4.get(999L) // => None
```

### Persistent Adaptive Radix Trees (PART)
- [论文](http://www3.informatik.tu-muenchen.de/~leis/papers/ART.pdf)
- [Github: Java实现](https://github.com/ankurdave/part)


### 实现分析

### References
- [Spark-2356](https://issues.apache.org/jira/browse/SPARK-2365)
- [Design Document](https://issues.apache.org/jira/secure/attachment/12656374/2014-07-07-IndexedRDD-design-review.pdf)
- [Spark Summit 2015 Slide](http://www.slideshare.net/SparkSummit/ankur-dave)
- [Spark Summit 2015 Video](https://www.youtube.com/watch?v=7NoFmrw1cV8&list=PL-x35fyliRwhP52fwDqULJLOnqnrN5nDs&index=5)
- [Github: IndexedRDD](https://github.com/amplab/spark-indexedrdd)
- [IndexedRDD：高效可更新的Key-value RDD](http://www.iteblog.com/archives/1259)
