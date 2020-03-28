
---
[首 页](https://patrickj-fd.github.io/index)
---

# 容器
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

# 镜像
## 构建镜像
```
sudo docker build -f Dockerfile文件 -t 镜像名:镜像TAG .
```

---
[首 页](https://patrickj-fd.github.io/index)
---

