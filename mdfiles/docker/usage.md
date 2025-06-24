[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 1. 容器
## 用容器执行命令
```shell
docker container run --rm -v /python/app/test:/opt/hrscode python-basic:3.6 python3 /opt/hrscode/hello.py
```

## 创建数据卷容器
```shell
docker container run -v 本地全路径名:容器内全路径名:ro --name THisDataVolumnName ubuntu:18.04 /bin/bash

# 这个容器的状态是"Exited"。
# 之后，任意容器在启动时可以直接引用该卷：
--volumes-from THisDataVolumnName 
```

## 启动和进入容器
```shell
# 启动到后台
sudo docker container run -d -p 38888:8888 --name 容器名 \
     -v 本地目录:容器目录 \
     --volumes-from 数据卷名 \
     镜像名
# --privileged

# 临时启动并进入
sudo docker container run --rm -it 镜像名 bash

# 进入一个已经启动的容器
sudo docker container exec -it 容器名 bash

```

## 查看容器
```shell
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
```shell
# 删除所有退出的容器
docker container rm $(docker container ls -a --filter status=exited | grep -v "CONTAINER ID" | awk '{print $1 }')
# sudo docker container rm $(docker container ls -a | grep "Exited" | awk '{print $1 }')
```

## 查看容器日志
```shell
docker logs 容器名      
docker logs -f 容器名    # 与 tail -f 同意义
```

## 容器提供 SSH 服务
```shell
apt install openssh-server
mkdir /run/sshd
# 允许root登录
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh start

# 给容器的root设置密码
echo "root:hmfms888" | chpasswd \
```

# 2. 镜像
## 构建镜像
```shell
sudo docker build -f Dockerfile文件 -t 镜像名:镜像TAG .
```

## 虚悬镜像
指没有仓库名，也没有标签名，皆为<none>的镜像。这类镜像原来是有仓库名和标签的，只不过，随着官方镜像的维护，这个镜像被重新发布了，以相同仓库名和标签名重新发布了。那么仓库名和标签名被转移到了新下载的镜像身上，而旧的镜像上的名称和标签都被取消了，从而成为了<none>
```shell
# 列出这些镜像
sudo docker image ls -f dangling=true
# 删除
sudo docker image prune
```
## 中间层镜像
为了加速镜像构建，重复利用资源，Docker会利用中间层镜像。  
默认的docker image ls列表中只会显示顶层镜像，如果希望显示包括中间层镜像在内的所有镜像的话，需要加上-a参数。
---

# 3. 其他
## 容器共享宿主机SSH端口
> http://www.ateijelo.com/blog/2016/07/09/share-port-22-between-docker-gogs-ssh-and-local-system

## 格式化输出
对于各个命令(ls/inspect ...)的屏幕输出，可使用 '--format' ，用GO模板进行格式化输出
```shell
docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
```
- format 详细用法参考：
> https://docs.docker.com/engine/reference/commandline/ps/#formatting

- filter 详细用法参考：
> https://docs.docker.com/engine/reference/commandline/ps/#Filtering

[首 页](https://patrickj-fd.github.io/index)
