# Docker on Mac初体验

## 在Docker中运行Bash
### 安装
```
$ brew cask install docker
```

### 下载镜像
```
$ docker pull daocloud.io/library/centos:6

$ docker images
```

### Docker中运行Bash
```
$ docker run --rm -i -t --name test daocloud.io/library/centos:6 /bin/bash
```

## 基本命令
### 命令查询
- [Docker Cheat Sheet](http://zeroturnaround.com/wp-content/uploads/2016/03/Docker-cheat-sheet-by-RebelLabs.png)
- [Docker Quick Ref](https://github.com/dimonomid/docker-quick-ref)

### 启动命令
```
# 启动容器，退出的时候容器停止，但是不删除
$ docker run -ti --name container_name image_name command

# 启动容器，退出的时候容容器自动删除
$ docker run --rm -ti --name container_name image_name command

# 端口映射，容器内部的8080端口映射成外部的80端口
$ docker run --rm -ti p 8080:80 --name container_name image_name command
```

### 退出命令
```
# 杀死所有正在运行的容器
$ docker kill $(docker ps -q)

# 删除所有停止的容器
$ docker rm $(docker ps -a -q)

# 删除所有未保存的镜像
$ docker rmi $(docker images -q -f dangling=true)
```

### 和容器进行交互
```
# 在容器中运行命令
$ docker exec -ti container_name command

# 查看容器日志
$ docker logs -ft container_name

# 把容器保存成镜像
$ docker commit -m "commit_message"  -a "author" container_name username/image_name:tag
```

## 打造自己的镜像
### 保存容器为镜像
```
# 启动容器
$ docker run -i -t --name test daocloud.io/library/centos:6 /bin/bash

# 在容器里安装软件
> yum install ...

# 把容器保存成镜像
$ docker commit -m "my_first_docker_image"  -a "author" test author/test:latest

# 查看生成的镜像
$ docker images
```

### Dockerfile

## 参考
- [Docker for Mac官方文档](https://docs.docker.com/docker-for-mac/)
- [Docker Resource All in One](https://github.com/hangyan/docker-resources/blob/master/README_zh.md)
- [Docker Spark](https://github.com/sequenceiq/docker-spark)
- [Docker基础技术：Linux Namespace（上）](http://coolshell.cn/articles/17010.html)
- [Docker基础技术：Linux Namespace（下）](http://coolshell.cn/articles/17029.html)
- [Docker基础技术：Linux CGroup](http://coolshell.cn/articles/17049.html)
- [Docker基础技术：AUFS](http://coolshell.cn/articles/17061.html)
- [Docker基础技术：DeviceMapper](http://coolshell.cn/articles/17200.html)
