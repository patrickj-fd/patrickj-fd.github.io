[首 页](https://patrickj-fd.github.io/index)

---

# 构建镜像
```
#!/bin/bash
set -e
# 【设置 .dockerignore】
cat > .dockerignore << EOF
# *表示将当前所有的目录下的文件都作为构建上下文的例外文件
*
EOF

# 【构建镜像】

DEV_SOFT_INSTALL='RUN  set -ex && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
     echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
     apt-get update && \
     apt-get install -y --no-install-recommends vim net-tools wget bzip2 unzip curl && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/* '

IMAGE_NAME="hrs-neo4j"
IMAGE_TAG="3.5"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM neo4j:3.5

ENV  TZ=Asia/Shanghai \
     LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
     NEO4J_AUTH=none

$DEV_SOFT_INSTALL

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
CAR_NAME="hrs-pgsql"
DATA_DIR="/tmp/data"
sudo docker container run -d --name $CAR_NAME \
     -p 37474:7474 -p 37687:7687 \
     -v $DATA_DIR:/data \
     hrs-neo4j:3.5
```

---

[首 页](https://patrickj-fd.github.io)
