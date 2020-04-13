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

IMAGE_NAME="hrs-postgresql"
IMAGE_TAG="11.7"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM postgres:11.7

ARG  PG_CNF_FILE="/etc/postgresql/postgresql.conf"
ENV  TZ=Asia/Shanghai \
     LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
	 POSTGRES_PASSWORD=HRS123321

# max_connections > ( max_wal_senders + superuser_reserved_connections )
RUN  set -ex && \
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
     apt-get install -y --no-install-recommends vim net-tools xz-utils wget bzip2 unzip curl && \

	 apt-get install -yq --no-install-recommends openssh-server && \
	 mkdir /run/sshd && \
     echo "root:hmfms888" | chpasswd && \
     echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \

     apt-get clean && \
     rm -rf /var/lib/apt/lists/* && \

     sed -i "s/^[[:space:]]*#[[:space:]]*listen_addresses.*/listen_addresses='*'/" $PG_CNF_FILE && \
     sed -i "s/^[[:space:]]*listen_addresses.*/listen_addresses='*'/" $PG_CNF_FILE && \

     sed -i "s/^[[:space:]]*#[[:space:]]*max_connections.*/max_connections=20/" $PG_CNF_FILE && \
     sed -i "s/^[[:space:]]*max_connections.*/max_connections=20/" $PG_CNF_FILE && \

     sed -i "s/^[[:space:]]*#[[:space:]]*shared_buffers.*/shared_buffers=32MB/" $PG_CNF_FILE && \
     sed -i "s/^[[:space:]]*shared_buffers.*/shared_buffers=32MB/" $PG_CNF_FILE

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
sudo docker container run -d -p 35432:5432 --name $CAR_NAME \
     -v $DATA_DIR:/var/lib/postgresql/data \
     -e POSTGRES_PASSWORD=123456 \
     hrs-postgresql:11.7 -c 'config_file=/etc/postgresql/postgresql.conf'
```

---

[首 页](https://patrickj-fd.github.io)
