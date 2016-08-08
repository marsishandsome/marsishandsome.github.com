# Docker原理

源码：[https://github.com/marsishandsome/playground/tree/master/docker-principal](https://github.com/marsishandsome/playground/tree/master/docker-principal)

## clone系统调用
[clone API文档](http://man7.org/linux/man-pages/man2/clone.2.html)

clone.c

```
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

/* 定义一个给 clone 用的栈，栈大小1M */
#define STACK_SIZE (1024 * 1024)
static char container_stack[STACK_SIZE];

char* const container_args[] = {
    "/bin/bash",
    NULL
};

int container_main(void* arg)
{
    printf("Container - inside the container!\n");
    /* 直接执行一个shell，以便我们观察这个进程空间里的资源是否被隔离了 */
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent - start a container!\n");
    /* 调用clone函数，其中传出一个函数，
     * 还有一个栈空间的（为什么传尾指针，因为栈是反着的） */
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            SIGCHLD, NULL);
    /* 等待子进程结束 */
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

```
./target/clone
Parent - start a container!
Container - inside the container!

ps
  PID TTY          TIME CMD
 9645 pts/13   00:00:00 clone
 9646 pts/13   00:00:00 bash
 9795 pts/13   00:00:00 ps
25829 pts/13   00:00:00 bash
```

## UTS Namespaces
uts.c

```
int container_main(void* arg)
{
    printf("Container - inside the container!\n");
    sethostname("container",10); /* 设置hostname */
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent - start a container!\n");
    /*启用CLONE_NEWUTS Namespace隔离 */
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | SIGCHLD, NULL);
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

```
./target/uts
Parent - start a container!
Container - inside the container!

[root@container docker-principal]# hostname
container

[root@container docker-principal]# uname -n
container
```

## IPC Namespaces
ipc.c

```
/*启用CLONE_NEWIPC Namespace隔离 */
int container_pid = clone(container_main, container_stack+STACK_SIZE,
        CLONE_NEWUTS | CLONE_NEWIPC | SIGCHLD, NULL);
```

```
ipcmk -Q
Message queue id: 0

ipcs -q
------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages    
0x2aa2fd9f 0          root       644        0            0           

./target/ipc
Parent - start a container!
Container - inside the container!

ipcs -q
------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages    
```

## PID Namespaces
pid.c

```
int container_main(void* arg)
{
    /* 查看子进程的PID，我们可以看到其输出子进程的 pid 为 1 */
    printf("Container [%5d] - inside the container!\n", getpid());
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent - start a container!\n");
    /*启用CLONE_NEWPID Namespace隔离 */
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | CLONE_NEWPID | SIGCHLD, NULL);
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

```
./target/pid
Parent - start a container!
Container [    1] - inside the container!

echo $$
1
```

## Mount Namespaces
mount.c

```
int container_main(void* arg)
{
    printf("Container [%5d] - inside the container!\n", getpid());
    sethostname("container",10);
    /* 重新mount proc文件系统到 /proc下 */
    system("mount -t proc proc /proc");
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent [%5d] - start a container!\n", getpid());
    /* 启用Mount Namespace - 增加CLONE_NEWNS参数 */
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | CLONE_NEWPID | CLONE_NEWNS | SIGCHLD, NULL);
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

```
/target/mount
Parent [13284] - start a container!
Container [    1] - inside the container!

ps -elf
F S UID        PID  PPID  C PRI  NI ADDR SZ WCHAN  STIME TTY          TIME CMD
4 S root         1     0  0  80   0 - 27082 wait   11:11 pts/13   00:00:00 /bin/bash
0 R root        30     1  0  80   0 - 27552 -      11:11 pts/13   00:00:00 ps -elf
```

## 山寨Docker
```
tree rootfs/
rootfs/
|-- bin
|   |-- bash
|   |-- cat
|   |-- ls
|   |-- mount
|   |-- ping
|   |-- ps
|   |-- pwd
|   `-- sh
|-- dev
|-- etc
|   |-- hostname
|   |-- hosts
|   `-- resolv.conf
|-- home
|-- lib
|-- lib64
|   |-- ld-linux-x86-64.so.2
|   |-- libacl.so.1
|   |-- libattr.so.1
|   |-- libcap.so.2
|   |-- libc.so.6
|   |-- libdl.so.2
|   |-- libidn.so.11
|   |-- libpcre.so.0
|   |-- libproc-3.2.8.so
|   |-- libpthread.so.0
|   |-- librt.so.1
|   |-- libselinux.so.1
|   `-- libtinfo.so.5
|-- mnt
|-- opt
|-- proc
|-- root
|   `-- etc
|-- run
|-- sbin
|-- sys
|-- tmp
|   `-- test
`-- usr
    `-- bin
        |-- clear
        |-- less
        |-- which
        `-- whoami

tree conf
conf
|-- hostname
|-- hosts
`-- resolv.conf
```

docker.c

```
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/mount.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

/* 定义一个给 clone 用的栈，栈大小1M */
#define STACK_SIZE (1024 * 1024)
static char container_stack[STACK_SIZE];

char* const container_args[] = {
    "/bin/bash",
    NULL
};

int container_main(void* arg)
{
    printf("Container [%5d] - inside the container!\n", getpid());

    // set hostname
    sethostname("container",10);

    //remount "/proc" to make sure the "top" and "ps" show container's information
    if (mount("proc", "rootfs/proc", "proc", 0, NULL) !=0 ) {
        perror("proc");
    }
    if (mount("sysfs", "rootfs/sys", "sysfs", 0, NULL)!=0) {
        perror("sys");
    }
    if (mount("none", "rootfs/tmp", "tmpfs", 0, NULL)!=0) {
        perror("tmp");
    }
    if (mount("udev", "rootfs/dev", "devtmpfs", 0, NULL)!=0) {
        perror("dev");
    }
    if (mount("devpts", "rootfs/dev/pts", "devpts", 0, NULL)!=0) {
        perror("dev/pts");
    }
    if (mount("shm", "rootfs/dev/shm", "tmpfs", 0, NULL)!=0) {
        perror("dev/shm");
    }
    if (mount("tmpfs", "rootfs/run", "tmpfs", 0, NULL)!=0) {
        perror("run");
    }

    /*
     * 模仿Docker的从外向容器里mount相关的配置文件
     * 你可以查看：/var/lib/docker/containers/<container_id>/目录，
     * 你会看到docker的这些文件的。
     */
    if (mount("conf/hosts", "rootfs/etc/hosts", "none", MS_BIND, NULL)!=0 ||
        mount("conf/hostname", "rootfs/etc/hostname", "none", MS_BIND, NULL)!=0 ||
        mount("conf/resolv.conf", "rootfs/etc/resolv.conf", "none", MS_BIND, NULL)!=0 ) {
        perror("conf");
    }

    /* 模仿docker run命令中的 -v, --volume=[] 参数干的事 */
    /*if (mount("/tmp/t1", "rootfs/mnt", "none", MS_BIND, NULL)!=0) {
       perror("mnt");
    }*/

    /* chroot 隔离目录 */
    if ( chdir("./rootfs") != 0 || chroot("./") != 0 ){
        perror("chdir/chroot");
    }

    execv(container_args[0], container_args);
    perror("exec");
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent [%5d] - start a container!\n", getpid());
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID | CLONE_NEWNS | SIGCHLD, NULL);
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

```
./target/docker
Parent [   36] - start a container!
Container [    1] - inside the container!

bash-4.1# ls /bin /usr/bin
/bin:
bash  cat  ls  mount  ping  ps  pwd  sh

/usr/bin:
clear  less  which  whoami

bash-4.1# mount
proc on /proc type proc (rw,relatime)
sysfs on /sys type sysfs (rw,relatime)
none on /tmp type tmpfs (rw,relatime)
udev on /dev type devtmpfs (rw,relatime,size=4018972k,nr_inodes=1004743,mode=755)
devpts on /dev/pts type devpts (rw,relatime,mode=600,ptmxmode=000)
shm on /dev/shm type tmpfs (rw,relatime)
tmpfs on /run type tmpfs (rw,relatime)
/dev/vdb on /etc/hosts type ext4 (rw,relatime,barrier=1,data=ordered)
/dev/vdb on /etc/hostname type ext4 (rw,relatime,barrier=1,data=ordered)
/dev/vdb on /etc/resolv.conf type ext4 (rw,relatime,barrier=1,data=ordered)
```

## CGroup
```
mkdir cgroup
mount -t tmpfs cgroup_root ./cgroup
mkdir cgroup/cpuset
mount -t cgroup -ocpuset cpuset ./cgroup/cpuset/
mkdir cgroup/cpu
mount -t cgroup -ocpu cpu ./cgroup/cpu/
mkdir cgroup/memory
mount -t cgroup -omemory memory ./cgroup/memory/
```

```
ls cgroup/cpu
cgroup.event_control  cpu.cfs_period_us  cpu.rt_period_us   cpu.shares  release_agent
cgroup.procs          cpu.cfs_quota_us   cpu.rt_runtime_us  cpu.stat    notify_on_release  tasks
```

```
mkdir cgroup/cpu/hello

ls cgroup/cpu/hello
ls cgroup/cpu/hello/
cgroup.event_control  cpu.cfs_quota_us   cpu.shares         tasks
cgroup.procs          cpu.rt_period_us   cpu.stat
cpu.cfs_period_us     cpu.rt_runtime_us  notify_on_release
```

### CPU
deadloop.c

```
int main(void)
{
    int i = 0;
    for(;;) i++;
    return 0;
}
```

```
./target/deadloop

top

PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
30272 root      20   0  3912  328  264 R 100.0  0.0   0:05.49 deadloop
```

```
echo 20000 > cgroup/cpu/hello/cpu.cfs_quota_us
echo 30272 > cgroup/cpu/hello/tasks

PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
30272 root      20   0  3912  328  264 R 19.8  0.0   2:18.95 deadloop
```

### Memory
memory.c

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

int main(void)
{
    int size = 0;
    int chunk_size = 512;
    void *p = NULL;

    while(1) {
        p = malloc(chunk_size);
        if (p == NULL) {
            printf("out of memory!!\n");
            break;
        }
        memset(p, 1, chunk_size);
        size += chunk_size;
        printf("[%d] - memory is allocated [%8d] bytes \n", getpid(), size);
        sleep(1);
    }
    return 0;
}
```

```
./target/memory

echo 64k > cgroup/memory/hello/memory.limit_in_bytes

echo 1058 > cgroup/memory/hello/tasks
```

<font color='red' size=18>没有效果，进程没有被kill！</font>

## 参考
- [Namespaces in operation, part 1: namespaces overview](http://lwn.net/Articles/531114/)
- [Docker基础技术：Linux Namespace（上）](http://coolshell.cn/articles/17010.html)
- [Docker基础技术：Linux Namespace（下）](http://coolshell.cn/articles/17029.html)
- [Docker基础技术：Linux CGroup](http://coolshell.cn/articles/17049.html)
- [Docker基础技术：AUFS](http://coolshell.cn/articles/17061.html)
- [Docker基础技术：DeviceMapper](http://coolshell.cn/articles/17200.html)
- [Docker Resource All in One](https://github.com/hangyan/docker-resources/blob/master/README_zh.md)
- [Bocker: Docker implemented in around 100 lines of bash](https://github.com/p8952/bocker)
