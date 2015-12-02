# Linux常用命令

## Network

### 端口
lsof -i:$port

### 进程所占用端口
netstat -ap | grep $pid
