# Paxos算法介绍

## 参考
- [Paxos论文](http://research.microsoft.com/en-us/um/people/lamport/pubs/lamport-paxos.pdf)
- [Paxos Made Simple](http://research.microsoft.com/en-us/um/people/lamport/pubs/paxos-simple.pdf)
- [Paxos和分布式系统 知行学社](http://www.tudou.com/programs/view/e8zM8dAL6hM/)

## Paxos要解决的问题
Paxos用来确定一个不可变量的取值，一旦确定将不再更改（不可变性），并且可以获取到（可读取性）。

一个分布式存储系统，可以存储名为var的变量
- 系统内部由多个Acceptor组成，负责存储和管理var
- 外部由多个Proposer机器任意并发调用API，向系统提交不同的var取值
- 系统对外API：propose(var, V) => (ok, f) or error

系统需要保证var取值满足一致性
- 如果var的取值没有确定，则var的取值为null
- 一旦var的取值被确定，则不可更改，并且可以一直获取到这个值

系统需要满足容错特性
- 可以容忍任意Proposer机器故障
- 可以容忍半数以下Acceptor机器故障

## 四个难点
1. Proposer并发管理
2. 保证var变量的不可变性
3. 容忍任意Proposer机器故障
4. 容忍半数以下Acceptor机器故障

## 方案一
### 思路
使用单个Acceptor，通过类似互斥锁机制管理并发Proposer
- Proposer首先想Acceptor申请互斥访问权，申请到了才能申请Acceptor接受自己的值
- Acceptor向Proposer发放互斥访问权，谁申请到了就接受谁的值
- 一旦Acceptor接受了某个Proposer的取值，则认为var的取值被确定，其他Proposer不能再更改

### 解决
1. Proposer并发
2. 保证var变量的不可变性

### Acceptor实现

```
var accepted_value = null
val lock = new Lock()

def prepare(): (Boolean, Object) = {
  (lock.tryLock(), acepted_value)
}

def release(): Unit = {
  lock.release()
}

def accept(value: Object): Object = {
  if(accepted_value == null) {
    accepted_value = value
  }
  release()
  accepted_value
}
```

### Proposer实现

```
def propose(value: Object): Object = {
  val (res, accepted_value) = prepare()
  if(accepted_value != null) {
    release()
    accepted_value
  } else {
    if(!res) {
      Thread.sleep(1000)
      propose(value)
    } else {
      accept(value)
    }
  }
}
```

## 方案二
### 问题
获得锁的Proposer机器故障会导致死锁

### 思路
引入抢占式访问权
- Acceptor可以让某个Proposer获得的访问权失效
- 之后可以把访问权发放给其他Proposer

Proposer向Acceptor申请访问权时指定编号epoch，获得访问权后才能向Acceptor提交取值

Acceptor采用喜新厌旧原则
- 一旦收到更大的epoch申请，马上让旧的epoch失效，不再接受旧的epoch的取值
- 然后给新的epoch发放访问权，只接收新的epoch的取值

为了保持一致性
- 在旧的epoch无法生成确定性取值时，新的epoch才会提交取值，不会冲突
- 一旦epoch形成确定性取值，新的epoch肯定可以获得该取值，并认同该取值

### 解决
- 容忍任意Propose机器故障

### Acceptor实现

```
var last_prepare_epoch: Integer = null
var accepted_epoch: Integer = null
var accepted_value: Object = null
val lock = new Lock()

def prepare(epoch: Integer): (Boolean, Integer, Object) = {
  lock.lock()
  var res = false
  if(last_prepare_epoch == null || epoch > last_prepare_epoch) {
    last_prepare_epoch = epoch
    res = true
  }
  lock.release()
  (res, accepted_epoch, accepted_value)
}

def accept(epoch: Integer, value: Object): (Boolean, Integer, Object) = {
  lock.lock()
  var res = false
  if(epoch == last_prepare_epoch && accepted_value == null) {
    accepted_value = value
    accepted_epoch = epoch
    res = true
  }
  lock.release()
  (res, accepted_epoch, accepted_value)
}
```

### Proposer实现

```
def propose(value: Object): Object {
  doPropose(value, 1)
}

private def doPropose(value: Object, epoch: Integer): Object = {
  val (res, accepted_epoch, accepted_value) = prepare(epoch, value))
  if(accepted_value != null) {
    accepted_value
  } else {
    if(!res) {
      Thread.sleep(1000)
      propose(value, accepted_epoch + 1)
    } else {
      doAccept(value, epoch)
    }
}

private def doAccept(value: Object, epoch: Integer): Object = {
  val (res, accepted_epoch, accepted_value) = accept(epoch, value)
  if(accepted_value != null) {
    accepted_value
  } else {
    Thread.sleep(1000)
    doPropose(value, accepted_epoch + 1)
  }
}
```

## 方案三
### 问题
Acceptor机器单点

### 思路
引入多个Acceptor

少数服从多数原则

某个epoch的取值f被半数以上Acceptor接受，则此var值被确定为f

Propose
- 第一阶段：选定epoch，获得半数以上Acceptor的访问权和对应的一组var取值
- 第二阶段：
	- 如果var取值为空，则旧的epoch无法取得确定性取值，努力使(epoch, V)成为确定性取值
	- 如果var取值存在，认同最大accepted_epoch对应的取值f，努力使(epoch, f)成为确定性取值

### 解决
- 容忍半数以下Acceptor机器故障

### Acceptor实现

```
同方案二
```

### Proposer实现

```
def acceptors: List[Acceptor]
def numOfAcceptors: Integer = acceptors.size

def propose(value: Object): Object {
  doPropose(value, 1)
}

private def doPropose(value: Object, epoch: Integer): Object = {}

private def doAccept(value: Object, epoch: Integer): Object = {
  val acceptResults = acceptors.map(_.accept(value, epoch))
															 .filter(成功返回结果的acceptor)

  if(acceptResults.size * 2 > numOfAcceptors) {
    val (_, maxEpoch, maybeValue) = acceptResults
		                                .filter(_._3 != null).sort(_._2).head
    val numOfMaxEpochValue = acceptResults.filter(_._3 == maybeValue)
    if(numOfMaxEpochValue * 2 >= numOfAcceptors) {
      maybeValue
    } else {
      Thread.sleep(1000)
      doPropose(maybeValue, maxEpoch + 1)
    }
  } else {
    Thread.sleep(1000)
    doPropose(value, epoch + 1)
  }
}
```

## 思考题
### 什么情况下可以认为var的取值被确定，不再更改？
半数以上Acceptor的值是一样的

### Paxos的两个阶段分别在做什么？
第一阶段获取修改访问权，第二阶段实施修改操作

### 一个epoch是否会有多个proposer进入第二个阶段？
不会，要进入第二阶段必须获得半数以上Acceptor的修改访问权，两个半数以上Accptor集合必然存在交集

### 在什么情况下，proposer可以将var的取值确定为自己提交的取值？
第二阶段提交后，返回的结果中半数以上是自己提交的值

### 在第二阶段，如果获取的var值都为空，为什么可以保证旧epoch无法形成确定性取值？
返回都为空，说明所有Acceptor都没有被设值，当旧的epoch尝试设值的时候，Acceptor会拒绝，因为last_prepare_epoch > 所有旧的epoch

### 新epoch抢占成功后，旧epoch的proposer将如何运行？
propose时无法获得半数以上Acceptor同意，根据不同的返回结果做相应的处理：
1. 如果有Acceptor已经被赋值，则取最大epoch的值，然后努力使该值成为确定性取值
2. 如果没有Acceptor被赋值，增加epoch，再次调用propose

### 如何保证新的epoch不会破坏已经达成的确定性取值？
如果已经达成了确定性取值，第一阶段获得半数以上Acceptor修改权限，并且其中必然存在一个Acceptor返回了该确定性取值，Proposer会抛弃自己的值，而努力使该值成为确定性取值

### 为什么在第二阶段存在var取值时，只需考虑accepted_epoch最大的取值f？
如果必须挑选一个的话，选accepted_epoch最大的，从概率上会更容易产生确定性取值

### 在形成确定性取值之后出现半数以下acceptor出现故障，此时将如何运行？
在正常的Acceptor中必然存在一个Acceptor的取值是出现故障前的确定性取值f，同时该Acceptor的accepted_epoch是最大的，当propose在第一阶段是，会获得该值f，并努力使f成为确定性取值

### 正在运行的proposer和任意半数以下acceptor都出现故障时，var的取值可能是什么情况？为何之后新proposer可以形成确定性取值？
如果存在Acceptor已经被赋值，那么新的Proposer会努力使最大epoch的值成为确定性取值，如果Acceptor都没有被赋值，Proposer会努力使自己的取值成为确定性取值
