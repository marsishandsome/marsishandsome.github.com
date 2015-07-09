# Learning Scala
- [Effective Scala](http://twitter.github.io/effectivescala/index.html) -- Twitter
- [Principles of Reactive Programming](https://class.coursera.org/reactive-002/auth) -- by Martin Odersky, Erik Meijer, Roland Kuhn
- [RxScala Github](https://github.com/ReactiveX/RxScala)

|              | One            | Many           |
| :----------- | :------------- | :------------- |
| Synchronous  | T / Try[T]     | Iterable[T]    |
| Asynchronous | Future[T]      | Observalbe[T]  |


### Monads
A monad M is a parametric type M[T] with two operations, flatMap and unit, that have to satisfy some laws.
```scala
trait M[T] {
  def flatMap[U](f: T => M[U]): M[U]
}

def unit[T](x: T): M[T]
```

To qualify as a monad, a type has to satisfy three laws:

Associativity
```
m flatMap f flatMap g == m flatMap (x => f(x) flatMap g)
```

Left unit
```
unit(x) flatMap f == f(x)
```

Right unit
```
m flatMap unit == m
```

### Try
```
abstract class Try[+T] {
  def flatMap[U](f: T => Try[U]): Try[U] = this match {
    case Success(x) => try f(x) catch { case NonFatal(ex) => Failure(ex) }
    case fail: Failure => fail
  }

  def map[U](f: T => U): Try[U] = this match {
    case Success(x) => Try(f(x))
    case fail: Failure => fail
  }

  def flatten[U <: Try[T]]: Try[U]
  def filter(p: T=>Boolean): Try[T]
  def recoverWith(f: PartialFunction[Throwable,Try[T]]): Try[T]
}

case class Success[T](x: T) extends Try[T]

case class Failure(ex: Exception) extends Try[Nothing]

object Try {
  def apply[T](expr: => T) {
    try {
      Success(expr)
    } catch {
      case NonFatal(ex) => Failure(ex)
    }
  }
}
```

### Future
```
tarit Awaitable[T] extends AnyRef {
  abstract def ready(atMost: Duration): Unit
  abstract def result(atMode: Duration): T
}

trait Future[T] {
  def onComplete(callback: Try[T] => Unit)(implicit executor: ExecutorContext): Unit
  def filter(p: T => Boolean): Future[T]
  def flatMap[U](f: T => Future[S]): Future[S]
  def map[U](f: T => U): Future[U]
  def recoverWith(f: PartialFunction[Throwable, Future[T]]): Future[T]
}

object Future {
  def apply(body: => T)
    (implicit executor: ExecutorContext): Future[T]
}
```

### Promise
```
trait Promise {
  def future: Future[T]
  def complete(result: Try[T]): Unit
  def tryComplete(result: Try[T]): Boolean
  def success(value: T): Unit = {
    this.complete(Success(value))
  }
  def failure(t: Throwable): Unit = {
    this.complete(Failure(t))
  }
}
```

### Iterable
```
trait Iterable[T] {
  def iterator: Iterator[T]
}

trait Iterator[T] {
  def hasNext(): Boolean
  def next(): T
}
```

### Observable
