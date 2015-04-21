# Spark on Yarn

### Links
- [YARN应用开发流程](http://my.oschina.net/u/1434348/blog/193374)
- [Spark on Yarn: a deep dive](http://www.chinastor.org/upload/2014-07/14070710043699.pdf) - Sandy Ryza @Cloudera
- [spark on yarn的技术挑战](http://dongxicheng.org/framework-on-yarn/spark-on-yarn-challenge/) - 董的博客
- [Apache Spark Resource Management and YARN App Models](http://blog.cloudera.com/blog/2014/05/apache-spark-resource-management-and-yarn-app-models/)
- [Apache Spark源码走读之8 -- Spark on Yarn](http://www.cnblogs.com/hseagle/p/3728713.html)


### Data Locality
使用preferredNodeLocationData

    val locData = InputFormatInfo.computePreferredLocations(
      Seq(new InputFormatInfo(conf, classOf[TextInputFormat], new Path("hdfs:///myfile.txt")))
    val sc = new SparkContext(conf, locData)


### Problems
1. Spark无法动态增加/减少资源，Container-Resizing [YARN-1197](https://issues.apache.org/jira/browse/YARN-1197)
2. [Timeline Store YARN-321](https://issues.apache.org/jira/browse/YARN-321)


### Yarn-Cluster模式
1: 提交Application

Client.submitApplication

    //新建一个Application
    val newApp = yarnClient.createApplication()
    val newAppResponse = newApp.getNewApplicationResponse()
    val appId = newAppResponse.getApplicationId()

    //1.1: 创建environment, java options以及启动AM的命令
    val containerContext = createContainerLaunchContext(newAppResponse)

    //1.2: 创建提交AM的Context，包括名字、队列、类型、内存、CPU及参数
    val appContext = createApplicationSubmissionContext(newApp, containerContext)

    //向Yarn提交Application
    yarnClient.submitApplication(appContext)


1.1: 创建environment, java options以及启动AM的命令

Client.createContainerLaunchContext

    val launchEnv = setupLaunchEnv(appStagingDir)
    val amContainer = Records.newRecord(classOf[ContainerLaunchContext])
    amContainer.setLocalResources(localResources)
    amContainer.setEnvironment(launchEnv)

    val amClass =
      if (isClusterMode) {
        Class.forName("org.apache.spark.deploy.yarn.ApplicationMaster").getName
      } else {
        Class.forName("org.apache.spark.deploy.yarn.ExecutorLauncher").getName
      }

    // Command for the ApplicationMaster
    val commands = prefixEnv ++ Seq(
        YarnSparkHadoopUtil.expandEnvironment(Environment.JAVA_HOME) + "/bin/java", "-server"
      ) ++
      javaOpts ++ amArgs ++
      Seq(
        "1>", ApplicationConstants.LOG_DIR_EXPANSION_VAR + "/stdout",
        "2>", ApplicationConstants.LOG_DIR_EXPANSION_VAR + "/stderr")
    val printableCommands = commands.map(s => if (s == null) "null" else s).toList
    amContainer.setCommands(printableCommands)

    // send the acl settings into YARN to control who has access via YARN interfaces
    val securityManager = new SecurityManager(sparkConf)
    amContainer.setApplicationACLs(YarnSparkHadoopUtil.getApplicationAclsForYarn(securityManager))
    setupSecurityToken(amContainer)
    UserGroupInformation.getCurrentUser().addCredentials(credentials)


1.2: 创建提交AM的Context，包括名字、队列、类型、内存、CPU及参数

Client.createApplicationSubmissionContext

    val appContext = newApp.getApplicationSubmissionContext
    appContext.setApplicationName(args.appName)
    appContext.setQueue(args.amQueue)
    appContext.setAMContainerSpec(containerContext)
    appContext.setApplicationType("SPARK")
    sparkConf.getOption("spark.yarn.maxAppAttempts").map(_.toInt) match {
      case Some(v) => appContext.setMaxAppAttempts(v)
      case None => logDebug("spark.yarn.maxAppAttempts is not set. " +
          "Cluster's default value will be used.")
    }
    val capability = Records.newRecord(classOf[Resource])
    capability.setMemory(args.amMemory + amMemoryOverhead)
    capability.setVirtualCores(args.amCores)
    appContext.setResource(capability)


2: 启动ApplicationMaster

ApplicationMaster.main

    val amArgs = new ApplicationMasterArguments(args)
    SparkHadoopUtil.get.runAsSparkUser { () =>
      master = new ApplicationMaster(amArgs, new YarnRMClient(amArgs))
      System.exit(master.run())
    }

ApplicationMaster.run

    if (isClusterMode) {
        runDriver(securityMgr)
      } else {
        runExecutorLauncher(securityMgr)
      }

ApplicationMaster.runDriver

    //配置IP Filter
    addAmIpFilter()

    //2.1 启动用户程序
    userClassThread = startUserApplication()

    //等待用户启动SC
    val sc = waitForSparkContextInitialized()

    if (sc == null) {
      finish(FinalApplicationStatus.FAILED,
        ApplicationMaster.EXIT_SC_NOT_INITED,
        "Timed out waiting for SparkContext.")
    } else {
      actorSystem = sc.env.actorSystem

      //2.2 启动AMActor
      runAMActor(
        sc.getConf.get("spark.driver.host"),
        sc.getConf.get("spark.driver.port"),
        isClusterMode = true)

      //2.3: 向RM注册AM相关信息(UIAddress、HistoryAddress、SecurityManager、SecurityManager、preferredNodeLocation)，并启动线程申请资源
      registerAM(sc.ui.map(_.appUIAddress).getOrElse(""), securityMgr)
      userClassThread.join()
    }

2.1 启动用户程序

startUserApplication

    val mainArgs = new Array[String](args.userArgs.size)
    args.userArgs.copyToArray(mainArgs, 0, args.userArgs.size)
    mainMethod.invoke(null, mainArgs)
    finish(FinalApplicationStatus.SUCCEEDED, ApplicationMaster.EXIT_SUCCESS)

SparkContext

    case "yarn-standalone" | "yarn-cluster" =>
        if (master == "yarn-standalone") {
          logWarning(
            "\"yarn-standalone\" is deprecated as of Spark 1.0. Use \"yarn-cluster\" instead.")
        }
        val scheduler = try {
          val clazz = Class.forName("org.apache.spark.scheduler.cluster.YarnClusterScheduler")
          val cons = clazz.getConstructor(classOf[SparkContext])
          cons.newInstance(sc).asInstanceOf[TaskSchedulerImpl]
        } catch {
          // TODO: Enumerate the exact reasons why it can fail
          // But irrespective of it, it means we cannot proceed !
          case e: Exception => {
            throw new SparkException("YARN mode not available ?", e)
          }
        }
        val backend = try {
          val clazz =
            Class.forName("org.apache.spark.scheduler.cluster.YarnClusterSchedulerBackend")
          val cons = clazz.getConstructor(classOf[TaskSchedulerImpl], classOf[SparkContext])
          cons.newInstance(scheduler, sc).asInstanceOf[CoarseGrainedSchedulerBackend]
        } catch {
          case e: Exception => {
            throw new SparkException("YARN mode not available ?", e)
          }
        }
        scheduler.initialize(backend)
        (backend, scheduler)
    
2.2 启动AMActor

ApplicationMaster.runAMActor

    actor = actorSystem.actorOf(Props(new AMActor(driverUrl, isClusterMode)), name = "YarnAM")

ApplicationMaster.AMActor
  
    override def preStart() = {
      driver = context.actorSelection(driverUrl)
      // Send a hello message to establish the connection, after which
      // we can monitor Lifecycle Events.
      driver ! "Hello"
      driver ! RegisterClusterManager
    }

    override def receive = {
      case x: DisassociatedEvent =>
        // In cluster mode, do not rely on the disassociated event to exit
        // This avoids potentially reporting incorrect exit codes if the driver fails
        if (!isClusterMode) {
          finish(FinalApplicationStatus.SUCCEEDED, ApplicationMaster.EXIT_SUCCESS)
        }

      case x: AddWebUIFilter =>
        driver ! x

      case RequestExecutors(requestedTotal) =>
        Option(allocator) match {
          case Some(a) => a.requestTotalExecutors(requestedTotal)
          case None => logWarning("Container allocator is not ready to request executors yet.")
        }
        sender ! true

      case KillExecutors(executorIds) =>
        Option(allocator) match {
          case Some(a) => executorIds.foreach(a.killExecutor)
          case None => logWarning("Container allocator is not ready to kill executors yet.")
        }
        sender ! true
    }


2.3: 向RM注册AM相关信息(UIAddress、HistoryAddress、SecurityManager、SecurityManager、preferredNodeLocation)，并启动线程申请资源

ApplicationMaster.registerAM

    allocator = client.register(yarnConf,
      if (sc != null) sc.getConf else sparkConf,
      if (sc != null) sc.preferredNodeLocationData else Map(),
      uiAddress,
      historyAddress,
      securityMgr)

    allocator.allocateResources()

    //2.4: launchReporterThread
    reporterThread = launchReporterThread()


2.4: launchReporterThread

ApplicationMaster.launchReporterThread

    if (allocator.getNumExecutorsFailed >= maxNumExecutorFailures) {
      finish(FinalApplicationStatus.FAILED,
        ApplicationMaster.EXIT_MAX_EXECUTOR_FAILURES,
        "Max number of executor failures reached")
    } else {
      logDebug("Sending progress")
      allocator.allocateResources()
    }


3: 申请并启动Container
3.1: YarnAllocator

API

    def getNumExecutorsRunning: Int = numExecutorsRunning
    def getNumExecutorsFailed: Int = numExecutorsFailed
    def getNumPendingAllocate: Int = getNumPendingAtLocation(ANY_HOST)

    def requestTotalExecutors(requestedTotal: Int)
    def killExecutor(executorId: String)
    def allocateResources(): Unit
    def updateResourceRequests(): Unit

YarnAllocator.allocateResources

    updateResourceRequests()
    val allocateResponse = amClient.allocate(progressIndicator)
    val allocatedContainers = allocateResponse.getAllocatedContainers()
    if (allocatedContainers.size > 0) {
      handleAllocatedContainers(allocatedContainers)
    }
    val completedContainers = allocateResponse.getCompletedContainersStatuses()
    if (completedContainers.size > 0) {
      processCompletedContainers(completedContainers)
    }

YarnAllocator.updateResourceRequests

    val numPendingAllocate = getNumPendingAllocate
    val missing = targetNumExecutors - numPendingAllocate - numExecutorsRunning

    if (missing > 0) {
      for (i <- 0 until missing) {
        val request = new ContainerRequest(resource, null, null, RM_REQUEST_PRIORITY)
        amClient.addContainerRequest(request)
        val nodes = request.getNodes
        val hostStr = if (nodes == null || nodes.isEmpty) "Any" else nodes.last
      }
    } else if (missing < 0) {
      val numToCancel = math.min(numPendingAllocate, -missing)
      val matchingRequests = amClient.getMatchingRequests(RM_REQUEST_PRIORITY, ANY_HOST, resource)
      if (!matchingRequests.isEmpty) {
        matchingRequests.head.take(numToCancel).foreach(amClient.removeContainerRequest)
      } else {
        logWarning("Expected to find pending requests, but found none.")
      }
    }


3.2: AMRMClient[ContainerRequest]

getNumPendingAtLocation

    amClient.getMatchingRequests(RM_REQUEST_PRIORITY, location, resource).map(_.size).sum

allocateResources

    amClient.allocate(progressIndicator)

updateResourceRequests  

    val request = new ContainerRequest(resource, null, null, RM_REQUEST_PRIORITY)
    amClient.addContainerRequest(request)

    amClient.getMatchingRequests(RM_REQUEST_PRIORITY, ANY_HOST, resource)
    if (!matchingRequests.isEmpty) {
          matchingRequests.head.take(numToCancel).foreach(amClient.removeContainerRequest)
        } else {
          logWarning("Expected to find pending requests, but found none.")
        }

internalReleaseContainer

    amClient.releaseAssignedContainer(container.getId())


3.3: ExecutorRunnable

run

    nmClient = NMClient.createNMClient()
    nmClient.init(yarnConf)
    nmClient.start()
    startContainer

startContainer

    val ctx = Records.newRecord(classOf[ContainerLaunchContext])
      .asInstanceOf[ContainerLaunchContext]

    val localResources = prepareLocalResources
    ctx.setLocalResources(localResources)

    ctx.setEnvironment(env)

    val credentials = UserGroupInformation.getCurrentUser().getCredentials()
    val dob = new DataOutputBuffer()
    credentials.writeTokenStorageToStream(dob)
    ctx.setTokens(ByteBuffer.wrap(dob.getData()))

    val commands = prepareCommand(masterAddress, slaveId, hostname, executorMemory, executorCores,
      appId, localResources)

    ctx.setCommands(commands)
    ctx.setApplicationACLs(YarnSparkHadoopUtil.getApplicationAclsForYarn(securityMgr))

    if (sparkConf.getBoolean("spark.shuffle.service.enabled", false)) {
      val secretString = securityMgr.getSecretKey()
      val secretBytes =
        if (secretString != null) {
          // This conversion must match how the YarnShuffleService decodes our secret
          JavaUtils.stringToBytes(secretString)
        } else {
          // Authentication is not enabled, so just provide dummy metadata
          ByteBuffer.allocate(0)
        }
      ctx.setServiceData(Map[String, ByteBuffer]("spark_shuffle" -> secretBytes))
    }

    nmClient.startContainer(container, ctx)


### Yarn-Client模式
4: 触发提交Application的过程

SparkContext

    case "yarn-client" =>
        val scheduler = try {
          val clazz =
            Class.forName("org.apache.spark.scheduler.cluster.YarnScheduler")
          val cons = clazz.getConstructor(classOf[SparkContext])
          cons.newInstance(sc).asInstanceOf[TaskSchedulerImpl]

        } catch {
          case e: Exception => {
            throw new SparkException("YARN mode not available ?", e)
          }
        }

        val backend = try {
          val clazz =
            Class.forName("org.apache.spark.scheduler.cluster.YarnClientSchedulerBackend")
          val cons = clazz.getConstructor(classOf[TaskSchedulerImpl], classOf[SparkContext])
          cons.newInstance(scheduler, sc).asInstanceOf[CoarseGrainedSchedulerBackend]
        } catch {
          case e: Exception => {
            throw new SparkException("YARN mode not available ?", e)
          }
        }

        scheduler.initialize(backend)
        (backend, scheduler)

YarnClientSchedulerBackend.start

    val argsArrayBuf = new ArrayBuffer[String]()
    argsArrayBuf += ("--arg", hostport)
    argsArrayBuf ++= getExtraClientArguments

    val args = new ClientArguments(argsArrayBuf.toArray, conf)
    totalExpectedExecutors = args.numExecutors
    client = new Client(args, conf)
    
    //同1: 提交Application
    appId = client.submitApplication()
    waitForApplication()
    asyncMonitorApplication()


5: ApplicationMaster (和2中cluster模式稍有不同）

ApplicationMaster.run

    if (isClusterMode) {
      runDriver(securityMgr)
    } else {
      runExecutorLauncher(securityMgr)
    }

ApplicationMaster.runExecutorLauncher

    actorSystem = AkkaUtils.createActorSystem("sparkYarnAM", Utils.localHostName, 0,
      conf = sparkConf, securityManager = securityMgr)._1
    waitForSparkDriver()
    addAmIpFilter()
    registerAM(sparkConf.get("spark.driver.appUIAddress", ""), securityMgr)

    // In client mode the actor will stop the reporter thread.
    reporterThread.join()

ApplicationMaster.waitForSparkDriver

    var driverUp = false
    val hostport = args.userArgs(0)
    val (driverHost, driverPort) = Utils.parseHostPort(hostport)

    // Spark driver should already be up since it launched us, but we don't want to
    // wait forever, so wait 100 seconds max to match the cluster mode setting.
    val totalWaitTime = sparkConf.getLong("spark.yarn.am.waitTime", 100000L)
    val deadline = System.currentTimeMillis + totalWaitTime

    while (!driverUp && !finished && System.currentTimeMillis < deadline) {
      try {
        val socket = new Socket(driverHost, driverPort)
        socket.close()
        logInfo("Driver now available: %s:%s".format(driverHost, driverPort))
        driverUp = true
      } catch {
        case e: Exception =>
          logError("Failed to connect to driver at %s:%s, retrying ...".
            format(driverHost, driverPort))
          Thread.sleep(100L)
      }
    }

    if (!driverUp) {
      throw new SparkException("Failed to connect to driver!")
    }

    sparkConf.set("spark.driver.host", driverHost)
    sparkConf.set("spark.driver.port", driverPort.toString)

    runAMActor(driverHost, driverPort.toString, isClusterMode = false)

