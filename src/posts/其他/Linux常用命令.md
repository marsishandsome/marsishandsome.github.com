# Linux常用命令

## 进程

### 查看进程数
ps axf

## Network

### 端口
lsof -i:$port

### 进程所占用端口
netstat -ap | grep $pid
