# Java Serialization Problem

### 问题： 序列化Scala函数的时候，为什么需要参数的类的定义？
今天在序列化一个Scala的函数的时候，碰到一个java序列化的问题，程序如下：
```
import java.io.{FileOutputStream, ObjectOutputStream}
import org.apache.spark.rdd.RDD

object Test {
  def main(args: Array[String]): Unit ={
    val obj: RDD[Int] => Int = rdd => rdd.first()
    val oout = new ObjectOutputStream(new FileOutputStream("/tmp/obj"))
    oout.writeObject(obj)
  }
}
```

Maven配置中，spark-core设为provided，因为在运行时上述程序是不需要加载RDD的类。
```
<dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-core_2.10</artifactId>
    <version>${spark.version}</version>
    <scope>provided</scope>
</dependency>
```

结果运行时出现了如下的错误：
```
Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/spark/rdd/RDD
	at java.lang.Class.getDeclaredMethods0(Native Method)
	at java.lang.Class.privateGetDeclaredMethods(Class.java:2570)
	at java.lang.Class.getDeclaredMethod(Class.java:2002)
	at java.io.ObjectStreamClass.getPrivateMethod(ObjectStreamClass.java:1431)
	at java.io.ObjectStreamClass.access$1700(ObjectStreamClass.java:72)
	at java.io.ObjectStreamClass$2.run(ObjectStreamClass.java:494)
	at java.io.ObjectStreamClass$2.run(ObjectStreamClass.java:468)
	at java.security.AccessController.doPrivileged(Native Method)
	at java.io.ObjectStreamClass.<init>(ObjectStreamClass.java:468)
	at java.io.ObjectStreamClass.lookup(ObjectStreamClass.java:365)
	at java.io.ObjectOutputStream.writeObject0(ObjectOutputStream.java:1133)
	at java.io.ObjectOutputStream.writeObject(ObjectOutputStream.java:347)
	at com.iqiyi.jupiter.Test$.main(Test.scala:20)
	at com.iqiyi.jupiter.Test.main(Test.scala)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:57)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:606)
	at com.intellij.rt.execution.application.AppMain.main(AppMain.java:140)
Caused by: java.lang.ClassNotFoundException: org.apache.spark.rdd.RDD
	at java.net.URLClassLoader$1.run(URLClassLoader.java:366)
	at java.net.URLClassLoader$1.run(URLClassLoader.java:355)
	at java.security.AccessController.doPrivileged(Native Method)
	at java.net.URLClassLoader.findClass(URLClassLoader.java:354)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:425)
	at sun.misc.Launcher$AppClassLoader.loadClass(Launcher.java:308)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:358)
	... 19 more
```  

### 分析
Scala的函数```val obj: RDD[Int] => Int = rdd => rdd.first()```会被翻译为Function类
```
val obj1 = new Function1[RDD[Int], Int]() {
  override def apply(v1: RDD[Int]): Int = {
    rdd.first()
  }
}
```

根据错误的stack信息，可以推测出Java在序列化Functoin1这个类的时候加载了RDD的类。原因如下：

如果用户在类里面定义了writeObject方法，Java会优先选择这个方法来序列化该类。所以Java会首先通过反射的机制检查类中有没有writeObject方法
```
ObjectStreamClass.java

getPrivateMethod(cl, "writeObject",
                  new Class<?>[] { ObjectOutputStream.class },
                  Void.TYPE);
```

在检查有没有writeObject方法的时候，调用了getDeclaredMethod获取所有的方法
```
private static Method getPrivateMethod(Class<?> cl, String name,
                                           Class<?>[] argTypes,
                                           Class<?> returnType)
    {
        try {
            Method meth = cl.getDeclaredMethod(name, argTypes);
            meth.setAccessible(true);
            int mods = meth.getModifiers();
            return ((meth.getReturnType() == returnType) &&
                    ((mods & Modifier.STATIC) == 0) &&
                    ((mods & Modifier.PRIVATE) != 0)) ? meth : null;
        } catch (NoSuchMethodException ex) {
            return null;
        }
    }
```

getDeclaredMethod中调用了privateGetDeclaredMethods
```
public Method getDeclaredMethod(String name, Class<?>... parameterTypes)
        throws NoSuchMethodException, SecurityException {
        // be very careful not to change the stack depth of this
        // checkMemberAccess call for security reasons
        // see java.lang.SecurityManager.checkMemberAccess
        checkMemberAccess(Member.DECLARED, Reflection.getCallerClass(), true);
        Method method = searchMethods(privateGetDeclaredMethods(false), name, parameterTypes);
        if (method == null) {
            throw new NoSuchMethodException(getName() + "." + name + argumentTypesToString(parameterTypes));
        }
        return method;
    }
```

privateGetDeclaredMethods中调用了getDeclaredMethods0，该方法是一个native方法,getDeclaredMethods0会寻找所有方法中涉及到的类的定义，所以会出现RDD类找不到的错误。
```
private Method[] privateGetDeclaredMethods(boolean publicOnly) {
       checkInitted();
       Method[] res = null;
       if (useCaches) {
           clearCachesOnClassRedefinition();
           if (publicOnly) {
               if (declaredPublicMethods != null) {
                   res = declaredPublicMethods.get();
               }
           } else {
               if (declaredMethods != null) {
                   res = declaredMethods.get();
               }
           }
           if (res != null) return res;
       }
       // No cached value available; request value from VM
       res = Reflection.filterMethods(this, getDeclaredMethods0(publicOnly));
       if (useCaches) {
           if (publicOnly) {
               declaredPublicMethods = new SoftReference<>(res);
           } else {
               declaredMethods = new SoftReference<>(res);
           }
       }
       return res;
   }
```

### 解决
因为所有出现在Function1方法中的类型都需要存在在运行时环境中，所以我们可以定义一个Wrapper类来包装RDD。这样Java只会查找Wrapper类，而不需要RDD类。

```
import java.io.{FileOutputStream, ObjectOutputStream}
import org.apache.spark.rdd.RDD

class Wrapper[T](@transient val value: T)

object Test {
  def main(args: Array[String]): Unit ={
    val obj: Wrapper[RDD[Int]] => Int = rdd => rdd.value.first()
    val oout = new ObjectOutputStream(new FileOutputStream("/tmp/obj"))
    oout.writeObject(obj)
  }
}
```

### 思考
个人觉得这个可以算一个Java的bug，getPrivateMethod方法只捕获了NoSuchMethodException，其实应该再捕获一个NoClassDefFoundError。
