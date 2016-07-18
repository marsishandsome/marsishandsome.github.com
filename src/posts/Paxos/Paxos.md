# Paxos

## 参考
- [Paxos论文](http://research.microsoft.com/en-us/um/people/lamport/pubs/lamport-paxos.pdf)
- [Paxos Made Simple](http://research.microsoft.com/en-us/um/people/lamport/pubs/paxos-simple.pdf)
- [Paxos和分布式系统 知行学社](http://www.tudou.com/programs/view/e8zM8dAL6hM/)

## Paxos要解决的问题
Paxos用来确定一个不可变量的取值，一旦确定将不再更改（不可变性），并且可以获取到（可读取性）。

- 一个分布式存储系统，可以存储名为var的变量
  - 系统内部由多个Acceptor组成，负责存储和管理var
  - 外部由多个Proposer机器任意并发调用API，向系统提交不同的var取值
  - 系统对外API：propose(var, V) => <ok, f> or <error>

- 系统需要保证var取值满足一致性
  - 如果var的取值没有确定，则var的取值为null
  - 一旦var的取值被确定，则不可更改，并且可以一直获取到这个值

- 系统需要满足容错特性
  - 可以容忍任意Proposer机器故障
  - 可以容忍半数以下Acceptor机器故障

## 四个难点
1. Proposer并发管理
2. 保证var变量的不可变性
3. 容忍任意Proposer机器故障
4. 容忍半数以下Acceptor机器故障

## 方案一
思路： 使用单个Acceptor，通过类似互斥锁机制管理并发Proposer

解决： 1. Proposer并发 2. 保证var变量的不可变性

- Proposer首先想Acceptor申请互斥访问权，申请到了才能申请Acceptor接受自己的值
- Acceptor向Proposer发放互斥访问权，谁申请到了就接受谁的值
- 一旦Acceptor接受了某个Proposer的取值，则认为var的取值被确定，其他Proposer不能再更改

Acceptor实现

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

Proposer实现

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
问题： 获得锁的Acceptor机器故障会导致死锁

思路： 引入抢占式访问权

解决： 3. 容忍任意Propose机器故障

- 引入抢占式访问权
  - Acceptor可以让某个Proposer获得的访问权失效
  - 之后可以把访问权发放给其他Proposer
- Proposer向Acceptor申请访问权时指定编号epoch，获得访问权后才能向Acceptor提交取值
- Acceptor采用喜新厌旧原则
  - 一旦收到更大的epoch申请，马上让旧的epoch失效，不再接受旧的epoch的取值
  - 然后给新的epoch发放访问权，只接收新的epoch的取值
- 为了保持一致性
  - 在旧的epoch无法生成确定性取值时，新的epoch才会提交取值，不会冲突
  - 一旦epoch形成确定性取值，新的epoch肯定可以获得该取值，并认同该取值


Acceptor实现

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

Proposer实现

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
问题： Acceptor机器单点

思路： 引入多个Acceptor

解决： 4. 容忍半数以下Acceptor机器故障

- 少数服从多数原则
- 某个epoch的取值f被半数以上Acceptor接受，则次var值被确定为f
- Propose
  - 第一阶段：选定epoch，获得半数以上Acceptor的访问权和对应的一组var取值
  - 第二阶段：
    - 如果var取值为空，则旧的epoch无法取得确定性取值，努力使<epoch, V>成为确定性取值
    - 如果var取值存在，认同最大accepted_epoch对应的取值f，努力使<epoch, f>成为确定性取值


Acceptor实现
```
同方案二
```

Proposer实现

```
def acceptors: List[Acceptor]
def numOfAcceptors: Integer = acceptors.size

def propose(value: Object): Object {
  doPropose(value, 1)
}

private def doPropose(value: Object, epoch: Integer): Object = {
  val prepareResults = acceptors.map(_.prepare(epoch, value)).filter(返回结果的acceptor)

  if(prepareResults.size * 2 > numOfAcceptors) {
    if(prepareResults.exists(_._3 != null) {
      val (_, maxEpoch, maybeValue) = prepareResults.filter(_._3 != null).sort(_._2)
      val numOfMaxEpochValue = prepareResults.filter(_._3 == maybeValue)
      if(numOfMaxEpochValue * 2 >= numOfAcceptors) {
        doAccept(maybeValue, epoch)
      } else {
        Thread(1000)
        doPropose(maxEpochValue, epoch + 1)
      }
    } else {
        doAccept(value, epoch)
    }
  } else {
    Thread.sleep(1000)
    doPropose(value, epoch + 1)
  }
}

private def doAccept(value: Object, epoch: Integer): Object = {
  val acceptResults = acceptors.map(_.accept(value, epoch)).filter(返回结果的acceptor)

  if(acceptResults.size * 2 > numOfAcceptors) {
    val (_, maxEpoch, maybeValue) = acceptResults.filter(_._3 != null).sort(_._2)
    val numOfMaxEpochValue = acceptResults.filter(_._3 == maybeValue)
    if(numOfMaxEpochValue * 2 >= numOfAcceptors) {
      maybeValue
    } else {
      Thread.sleep(1000)
      doPropose(value, epoch + 1)
    }
  } else {
    Thread.sleep(1000)
    doPropose(value, epoch + 1)
  }
}
```

## Paxos的应用
- 多副本更新操作序列
- Chubby
- Megastore
- Spanner
- Zookeeper
