# Maven常用插件

##  Properties
```
<properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    <PermGen>64m</PermGen>
    <MaxPermGen>512m</MaxPermGen>
    <CodeCacheSize>512m</CodeCacheSize>
    <java.version>1.7</java.version>
    <scala.version>2.10.4</scala.version>
    <scala.binary.version>2.10</scala.binary.version>
    <scala.macros.version>2.0.1</scala.macros.version>
</properties>
```

## Scala Maven plugin
- [Scala Maven Plugin](http://davidb.github.io/scala-maven-plugin/)
- [Github](https://github.com/davidB/scala-maven-plugin)

Scala的Maven插件，常用配置包括
- 增量式编译
- Zinc服务器，加速编译
- Scala编译参数
- Java编译参数
- JVM启动参数

```
<plugin>
    <groupId>net.alchim31.maven</groupId>
    <artifactId>scala-maven-plugin</artifactId>
    <version>3.2.0</version>
    <executions>
      <execution>
              <id>eclipse-add-source</id>
              <goals>
                <goal>add-source</goal>
              </goals>
            </execution>
        <execution>
            <id>scala-compile-first</id>
            <phase>process-resources</phase>
            <goals>
                <goal>compile</goal>
            </goals>
        </execution>
        <execution>
            <id>scala-test-compile-first</id>
            <phase>process-test-resources</phase>
            <goals>
                <goal>testCompile</goal>
            </goals>
        </execution>
        <execution>
              <id>attach-scaladocs</id>
              <phase>verify</phase>
              <goals>
                <goal>doc-jar</goal>
              </goals>
            </execution>
    </executions>
    <configuration>
        <scalaVersion>${scala.version}</scalaVersion>
        <recompileMode>incremental</recompileMode>
        <useZincServer>true</useZincServer>
        <args>
            <arg>-unchecked</arg>
            <arg>-deprecation</arg>
            <arg>-feature</arg>gs>
        </args>
        <javacArgs>
            <javacArg>-source</javacArg>
            <javacArg>${java.version}</javacArg>
            <javacArg>-target</javacArg>
            <javacArg>${java.version}</javacArg>
            <javacArg>-Xlint:all,-serial,-path</javacArg>
        </javacArgs>
        <jvmArgs>
            <jvmArg>-Xms1024m</jvmArg>
            <jvmArg>-Xmx1024m</jvmArg>
            <jvmArg>-XX:PermSize=${PermGen}</jvmArg>
            <jvmArg>-XX:MaxPermSize=${MaxPermGen}</jvmArg>
            <jvmArg>-XX:ReservedCodeCacheSize=${CodeCacheSize}</jvmArg>
        </jvmArgs>
    </configuration>
</plugin>
```

## Maven Compiler Plugin
- [Maven Compiler Plugin](https://maven.apache.org/plugins/maven-compiler-plugin/)

```
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.3</version>
  <configuration>
    <source>${java.version}</source>
    <target>${java.version}</target>
    <encoding>UTF-8</encoding>
    <maxmem>1024m</maxmem>
    <fork>true</fork>
    <compilerArgs>
      <arg>-Xlint:all,-serial,-path</arg>
    </compilerArgs>
  </configuration>
</plugin>
```

## Maven Shade Plugin
- [Maven Shade Plugin](https://maven.apache.org/plugins/maven-shade-plugin/)

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>2.4.2</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <shadedArtifactAttached>false</shadedArtifactAttached>
                <artifactSet>
                    <includes>
                        <include>*:*</include>
                    </includes>
                </artifactSet>
                <filters>
                    <filter>
                        <artifact>*:*</artifact>
                        <excludes>
                            <exclude>META-INF/*.SF</exclude>
                            <exclude>META-INF/*.DSA</exclude>
                            <exclude>META-INF/*.RSA</exclude>
                        </excludes>
                    </filter>
                </filters>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## scalatest-maven-plugin
- [Website](http://www.scalatest.org/user_guide/using_the_scalatest_maven_plugin)
- [Github](https://github.com/scalatest/scalatest-maven-plugin)

```
<plugin>
    <groupId>org.scalatest</groupId>
    <artifactId>scalatest-maven-plugin</artifactId>
    <version>1.0</version>
    <configuration>
        <reportsDirectory>
            ${project.build.directory}/surefire-reports
        </reportsDirectory>
        <junitxml>.</junitxml>
        <filereports>${project.build.directory}/TestSuite.txt
        </filereports>
    </configuration>
    <executions>
        <execution>
            <id>test</id>
            <goals>
                <goal>test</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### maven-source-plugin
```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-source-plugin</artifactId>
    <version>2.4</version>
    <configuration>
        <attach>true</attach>
    </configuration>
    <executions>
        <execution>
            <id>create-source-jar</id>
            <goals>
                <goal>jar-no-fork</goal>
                <goal>test-jar-no-fork</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### builder-helper-maven-plugin
```
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>build-helper-maven-plugin</artifactId>
    <version>1.9.1</version>
    <executions>
        <execution>
            <id>add-scala-sources</id>
            <phase>generate-sources</phase>
            <goals>
                <goal>add-source</goal>
            </goals>
            <configuration>
                <sources>
                    <source>src/main/scala</source>
                </sources>
            </configuration>
        </execution>
        <execution>
            <id>add-scala-test-sources</id>
            <phase>generate-test-sources</phase>
            <goals>
                <goal>add-test-source</goal>
            </goals>
            <configuration>
                <sources>
                    <source>src/test/scala</source>
                </sources>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## maven-enforcer-plugin
- [Maven Enforcer Plugin](http://maven.apache.org/enforcer/maven-enforcer-plugin/)
- [Maven Enforcer Rules](http://maven.apache.org/enforcer/enforcer-rules/)
- [Rule: Dependency Convergence](http://maven.apache.org/enforcer/enforcer-rules/dependencyConvergence.html)
- [Fight Dependency Hell in Maven](http://cupofjava.de/blog/2013/02/01/fight-dependency-hell-in-maven/)

> If a project has two dependencies, A and B, both depending on the same artifact, C, this rule will fail the build if A depends on a different version of C then the version of C depended on by B.

```
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-enforcer-plugin</artifactId>
  <version>1.4.1</version>
  <executions>
    <execution>
      <id>enforce</id>
      <configuration>
        <rules>
          <dependencyConvergence/>
        </rules>
      </configuration>
      <goals>
        <goal>enforce</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```
