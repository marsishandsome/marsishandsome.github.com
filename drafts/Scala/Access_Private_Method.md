# Access Private Method


```
import org.apache.spark.{SparkConf, SparkContext}

object SimpleApp {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("name").setMaster("local")
    new SparkContext(conf)
    getActiveSparkContext.foreach { sc =>
      sc.parallelize(1 to 3).collect().foreach(println)
      sc.stop()
    }
  }

  def getActiveSparkContext: Option[SparkContext] = {
    val ru = scala.reflect.runtime.universe
    val mirror = ru.runtimeMirror(SparkContext.getClass.getClassLoader)
    val moduleSymbol = ru.typeOf[SparkContext.type].termSymbol.asModule
    val moduleMirror = mirror.reflectModule(moduleSymbol)
    val instanceMirror = mirror.reflect(moduleMirror.instance)
    val scMethod = ru.typeOf[SparkContext.type].declaration(ru.newTermName("activeContext")).asMethod
    val scMethodMirror = instanceMirror.reflectMethod(scMethod)
    val sc = scMethodMirror.apply().asInstanceOf[Option[SparkContext]]
    sc
  }
}
```
