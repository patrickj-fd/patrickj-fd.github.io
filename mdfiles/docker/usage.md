[首 页](https://patrickj-fd.github.io/index)

---
# 格式化输出
对于各个命令(ls/inspect ...)的屏幕输出，可使用 '--format' ，用GO模板进行格式化输出
```shell
docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
```
- format 详细用法参考：
> https://docs.docker.com/engine/reference/commandline/ps/#formatting

- filter 详细用法参考：
> https://docs.docker.com/engine/reference/commandline/ps/#Filtering

# 容器
## 创建数据卷容器
```
docker container run -v 本地全路径名:容器内全路径名:ro --name THisDataVolumnName ubuntu:18.04 /bin/bash

# 这个容器的状态是"Exited"。
# 之后，任意容器在启动时可以直接引用该卷：
--volumes-from THisDataVolumnName 
```

## 启动和进入容器
```
# 启动到后台
sudo docker container run -d -p 38888:8888 --name 容器名 \
     -v 本地目录:容器目录 \
     --volumes-from 数据卷名 \
     镜像名
# --privileged=true --gpus all

# 临时启动并进入
sudo docker container run --rm -it 镜像名 bash

# 进入一个已经启动的容器
sudo docker container exec -it 容器名 bash

```

## 查看容器
```
# 按照容器名字查找容器
docker container ls -a --filter name=DataVolumn

# 按照容器状态查找容器
docker container ls -a --filter status=exited

# 所有退出的容器
docker container ls -a --filter status=exited
docker container ls -a | grep "Exited"

# 找到指定名字的容器
docker container ls -a | grep -v "CONTAINER ID" | grep "要找的名字" | awk '{print $1 }'
# grep -v "CONTAINER ID" ：去掉了第一行的标题，免得因为"CONTAINER ID"中间的空格导致awk出问题
```

## 删除容器
```
# 删除所有退出的容器
docker container rm $(docker container ls -a --filter status=exited | grep -v "CONTAINER ID" | awk '{print $1 }')
# sudo docker container rm $(docker container ls -a | grep "Exited" | awk '{print $1 }')
```

## 查看容器日志
```
docker logs 容器名      
docker logs -f 容器名    # 与 tail -f 同意义
```

## 容器提供 SSH 服务
```
apt install openssh-server
mkdir /run/sshd
# 允许root登录
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh start

# 给容器的root设置密码
echo "root:hmfms888" | chpasswd \
```

# 镜像
## 构建镜像
```
sudo docker build -f Dockerfile文件 -t 镜像名:镜像TAG .
```

---

[首 页](https://patrickj-fd.github.io/index)
