#Future and Promise

### Future in Java

##### Future
- [jdk1.5](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html)

```java
interface Future<V> {
  boolean cancel(boolean mayInterruptIfRunning);
  boolean isCancelled();
  boolean isDone();
  V get() throws InterruptedException, ExecutionException;
}
```

##### ListenableFuture
- [guava](https://code.google.com/p/guava-libraries/wiki/ListenableFutureExplained)
- [api](http://docs.guava-libraries.googlecode.com/git/javadoc/com/google/common/util/concurrent/ListenableFuture.html)

```java
class SettableFuture<V> {
  public boolean set(@Nullable V value);
  public boolean setException(Throwable throwable)
}

interface ListenableFuture<V> extends SettableFuture<V> {
  void addListener(Runnable listener, Executor executor);
}

Class Futures {
  public static <V> void addCallback(ListenableFuture<V> future,
                   FutureCallback<? super V> callback);

  public static <I,O> ListenableFuture<O> transform(ListenableFuture<I> input,
                   Function<? super I,? extends O> function);
  ...
}
```

##### CompletableFuture
- [jdk1.8](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html)

```java
Class CompletableFuture<T> {
  public boolean complete(T value);

  public boolean completeExceptionally(Throwable ex)

  public <U> CompletableFuture<U> thenApply(Function<? super T,? extends U> fn);

  public <U,V> CompletableFuture<V> thenCombine(CompletionStage<? extends U> other,
                                BiFunction<? super T,? super U,? extends V> fn)

  public CompletableFuture<T> exceptionally(Function<Throwable,? extends T> fn)
  ...
}
```

### Future In Scala
```scala
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
  def apply(body: => T) (implicit executor: ExecutorContext): Future[T]
}
```

```scala
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

### Future In C++11
TODO

### References
- [Wikipedia](https://en.wikipedia.org/wiki/Futures_and_promises)
- [深入浅出Future Pattern](http://www.wuzesheng.com/?p=2485)
- [Java8 中的纯异步编程](http://www.tuicool.com/articles/ABVV3q)
- [Java中使用CompletableFuture处理异步超时](http://www.xker.com/page/e2015/06/198145.html)
- [Scalable Component Abstractions](http://lampwww.epfl.ch/~odersky/papers/ScalableComponent.pdf) -- Martin Odersky
- [RxScala Github](https://github.com/ReactiveX/RxScala)
- [Twitter: Concurrent Programming with Futures](http://twitter.github.io/finagle/guide/Futures.html)
- [Twitter: Effective Scala](http://twitter.github.io/effectivescala/index.html)
