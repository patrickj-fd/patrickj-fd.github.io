[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建镜像

```shell
#!/bin/bash
set -e
# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
EOF

# 【构建镜像】

IMAGE_NAME="hrs-gitrepo"
IMAGE_TAG="gogs"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM gogs/gogs

ENV  TZ=Asia/Shanghai 

EOF
# ----------------- Dockerfile End  -----------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 
```

# 启动容器
```
CAR_NAME="hrs-gitrepo-gogs"
DATA_DIR="/tmp/gogs/data"
sudo docker container run -d --name $CAR_NAME \
     -p 38111:3000 -p 38110:22 \
     -v $DATA_DIR:/data \
     hrs-gitrepo:gogs
```

# 注意

- 在WEB界面上进行初始安装配置时，端口要写3000和22，因为容器内部是使用这些端口。写错了的话，一旦容器被重启，就服务访问服务了
- 初始安装的所有配置，可以直接修改配置文件：gogs/conf/app.ini

---

[首 页](https://patrickj-fd.github.io)
