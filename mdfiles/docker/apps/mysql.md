[首 页](https://patrickj-fd.github.io/index)

---

# 构建镜像

```shell
#!/bin/bash
set -e
# 【设置 .dockerignore】
cat > .dockerignore << EOF
# *表示将当前所有的目录下的文件都作为构建上下文的例外文件
*
EOF

# 定义 mysql 配置文件
cat >./my.cnf.sample <<EOF
[mysqld]
user=mysql
character-set-server=utf8
default_authentication_plugin=mysql_native_password
max_connections=20
default-storage-engine=INNODB
lower_case_table_names=1
max_allowed_packet=32M
# Disabling symbolic-links is recommended to prevent assorted security risks
# symbolic-links=0
skip-name-resolve
# skip-grant-tables
[client]
default-character-set=utf8
[mysql]
default-character-set=utf8
EOF

# 【构建镜像】

IMAGE_NAME="hrs-mysql"
IMAGE_TAG="5.7"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM mysql:5.7

ARG  PG_CNF_FILE="/etc/postgresql/postgresql.conf"
ENV  TZ=Asia/Shanghai \
     LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
	MYSQL_ROOT_PASSWORD=HRS123321

# For SSH login
# apt-get install -yq --no-install-recommends openssh-server && \
# mkdir /run/sshd && \
# echo "root:hmfms888" | chpasswd && \
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
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
     apt-get install -y --no-install-recommends vim net-tools wget bzip2 unzip curl && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*

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
CAR_NAME="hrs-mysql"
DATA_DIR="/tmp/data"
LOGS_DIR="/tmp/logs"
sudo docker container run -d -p 33306:3306 --name $CAR_NAME \
     -v $PWD/my.cnf.sample:/etc/mysql/conf.d/my.cnf -v $DATA_DIR:/var/lib/mysql \
     -v $LOGS_DIR:/logs \
     -e MYSQL_ROOT_PASSWORD=123456 \
     hrs-mysql:5.7
```

---

[首 页](https://patrickj-fd.github.io)
