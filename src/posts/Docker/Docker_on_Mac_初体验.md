# Docker on Mac初体验

## 在Docker中运行Bash
### 安装
```
$ brew cask install docker
```

### 下载镜像
```
$ docker pull daocloud.io/library/centos:6
```

### Docker中运行Bash
```
$ docker run -i -t centos:6 /bin/bash
```

## 命令查询
[Docker Cheat Sheet](http://zeroturnaround.com/wp-content/uploads/2016/03/Docker-cheat-sheet-by-RebelLabs.png)
![](http://zeroturnaround.com/wp-content/uploads/2016/03/Docker-cheat-sheet-by-RebelLabs.png)

[Docker Quick Ref](https://github.com/dimonomid/docker-quick-ref)

## 参考
- [Docker for Mac官方文档](https://docs.docker.com/docker-for-mac/)
- [Docker Resource All in One](https://github.com/hangyan/docker-resources/blob/master/README_zh.md)
- [Docker Spark](https://github.com/sequenceiq/docker-spark)
- [Docker基础技术：Linux Namespace（上）](http://coolshell.cn/articles/17010.html)
- [Docker基础技术：Linux Namespace（下）](http://coolshell.cn/articles/17029.html)
- [Docker基础技术：Linux CGroup](http://coolshell.cn/articles/17049.html)
- [Docker基础技术：AUFS](http://coolshell.cn/articles/17061.html)
- [Docker基础技术：DeviceMapper](http://coolshell.cn/articles/17200.html)
