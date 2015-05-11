# Principles of Reactive Programming
- by Martin Odersky, Erik Meijer, Roland Kuhn
- [Coursera Link](https://class.coursera.org/reactive-002/auth)

# Week 1
### Collections
Translation of For:
1. map
```
for (x <- e1) yield e2
==>
e1.map(x => e2)
```
2. withFilter
```
for (x <- e1 if f; s) yield e2
==>
for (x <- e1.withFilter(x => f); s) yield e2
```
3. flatMap
```
for (x <- e1; y <- e2; s) yield e3
==>
e1.flatMap(x => for(y <- e2; s) yield e3)
```

### Functional Random Generators
Generator
```
trait Generator[+T] {
  def generate: T
}

val integers = new Generator[Int] {
  val rand = new java.util.Random
  def generate = rand.nextInt()
}

val booleans = new Generator[Boolean] {
  def generate = integers.generate > 0
}

val pairs = new Generator[(Int, Int)] {
  def generate = (integers.generate, integers.generate)
}
```

Streamlining
```
val booleans = for (x <- integers) yield x > 0
def pairs[T, U](t: Generator[T], u: Generator[U]) = for {
  x <- t
  y <- u
} yield (x, y)
```

Generator with map and flatMap
```
trait Generator[+T] {
  self =>
  def generate: T
  def map[S](f: T => S): Generator[S] = new Generator[S] {
    def generate = f(self.generate)
  }
  def flatMap[S](f: T => Generator[S]): Generator[S] = new Generator[S] {
    def generate = f(self.generate).generate
  }
}
```

### Monads
Monads定义:
```
trait M[T] {
def flatMap[U](f: T => M[U]): M[U]
}
def unit[T](x: T): M[T]
```

map定义:
```
m map f == m flatMap (x => unit(f(x)))
== m flatMap (f andThen unit)
```

Monads三大定律:
1. 结合律
```
m flatMap f flatMap g == m flatMap (x => f(x) flatMap g)
```
2. Left Unit
```
unit(x) flatMap f == f(x)
```
3. Right Unit
```
m flatMap unit == m
```

# Week 2
### Functions and State
### Identity and Change
### Loops
### Imperative Event Handling: The Observer Pattern
### Functional Reactive Programming
### A Simple FRP Implementation

# Week 3
### Monads and Effects
Try
```
abstract class Try[T] {
  def flatMap[S](f: T=>Try[S]): Try[S]
  def flatten[U <: Try[T]]: Try[U]
  def map[S](f: T=>S): Try[T]
  def filter(p: T=>Boolean): Try[T]
  def recoverWith(f: PartialFunction[Throwable,Try[T]]): Try[T]
}
case class Success[T](elem: T) extends Try[T]
case class Failure(t: Throwable) extends Try[Nothing]
```

Adventure
```
trait Adventure {
  def collectCoins(): Try[List[Coin]]
  def buyTreasure(coins: List[Coin]): Try[Treasure]
}
```

Dealing with failure explicitly
```
val adventure = Adventure()
val coins: Try[List[Coin]] = adventure.collectCoins()
val treasure: Try[Treasure] = coins match {
  case Success(cs) => adventure.buyTreasure(cs)
  case failure@Failure(e) => failure
}
```

Noise reduction: Flatmap
```
val adventure = Adventure()
val treasure: Try[Treasure] =
  adventure.collectCoins().flatMap { coins =>
  adventure.buyTreasure(coins)
}
```

Using comprehension syntax


### Latency as an Effect 1
### Latency as an Effect 2
### Combinator on Futures 1
### Combinator on Futures 2
### Composing Futures 1
### Composing Futures 2
### Async Await
### Promise, promises

# Week 4

# Week 5
