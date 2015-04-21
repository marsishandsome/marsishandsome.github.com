# Spark on Yarn

### Links for Yarn
- [YARN应用开发流程](http://my.oschina.net/u/1434348/blog/193374)


### Links for Spark on Yarn
- [spark on yarn的技术挑战](http://dongxicheng.org/framework-on-yarn/spark-on-yarn-challenge/) - 董的博客
- [Spark on Yarn: a deep dive](http://www.chinastor.org/upload/2014-07/14070710043699.pdf) - Sandy Ryza @Cloudera
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

    // Get a new application from our RM
    val newApp = yarnClient.createApplication()
    val newAppResponse = newApp.getNewApplicationResponse()
    val appId = newAppResponse.getApplicationId()

    // Set up the appropriate contexts to launch our AM
    val containerContext = createContainerLaunchContext(newAppResponse)
    val appContext = createApplicationSubmissionContext(newApp, containerContext)

    // Finally, submit and monitor the application
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


1.2: 创建提交AM的Context

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

2.1: Cluster模式启动Driver

ApplicationMaster.runDriver

    addAmIpFilter()
    userClassThread = startUserApplication()

    // This a bit hacky, but we need to wait until the spark.driver.port property has
    // been set by the Thread executing the user class.
    val sc = waitForSparkContextInitialized()

    // If there is no SparkContext at this point, just fail the app.
    if (sc == null) {
      finish(FinalApplicationStatus.FAILED,
        ApplicationMaster.EXIT_SC_NOT_INITED,
        "Timed out waiting for SparkContext.")
    } else {
      actorSystem = sc.env.actorSystem
      runAMActor(
        sc.getConf.get("spark.driver.host"),
        sc.getConf.get("spark.driver.port"),
        isClusterMode = true)
      registerAM(sc.ui.map(_.appUIAddress).getOrElse(""), securityMgr)
      userClassThread.join()
    }

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


2.3: registerAM

ApplicationMaster.registerAM

    allocator = client.register(yarnConf,
      if (sc != null) sc.getConf else sparkConf,
      if (sc != null) sc.preferredNodeLocationData else Map(),
      uiAddress,
      historyAddress,
      securityMgr)

    allocator.allocateResources()
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


