[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建镜像

```shell
#!/bin/bash

# 【设置 .dockerignore】
cat > .dockerignore << EOF
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
SOURCES_LIST=$(cat /data1/docker/apps/apt-sources.list)
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM mysql:5.7

ENV  TZ=Asia/Shanghai \\
     MYSQL_ROOT_PASSWORD=HRS123321

RUN  set -ex && \\
$SOURCES_LIST
     apt-get update && \\
     apt-get install -y --allow-unauthenticated --no-install-recommends vim wget curl && \\
     apt-get clean && \\
     rm -rf /var/lib/apt/lists/*

EOF
# ----------------- Dockerfile End  -----------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo "================================================================"
echo "image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "Checking it :"
echo "docker container run -d --name cartest-$IMAGE_NAME $IMAGE_NAME:$IMAGE_TAG"
echo "================================================================"
```

# 启动容器
```shell
CAR_NAME="hrs-mysql"
DATA_DIR="/data2/DockerUserWorkEnv/UserWorkfolder/mysql/data"
LOGS_DIR="/data2/DockerUserWorkEnv/UserWorkfolder/mysql/logs"
sudo docker container run -d -p 33306:3306 --name $CAR_NAME \
     -v $PWD/my.cnf.sample:/etc/mysql/conf.d/my.cnf -v $DATA_DIR:/var/lib/mysql \
     -v $LOGS_DIR:/logs \
     -e MYSQL_ROOT_PASSWORD=123456 \
     hrs-mysql:5.7
```

# 通过容器使用mysql客户端：
```shell
# 容器的IP：docker inspect 容器名 | grep IP
# 用临时容器的mysql客户端
docker container run --rm -it mysql:5.7 sh -c 'exec mysql -h"容器的IP" -uroot -p"123456"'
# 使用已经创建的容器
docker container exec -it yours_car_name sh -c "exec mysql -h容器的IP -uroot -p123456"
```

# 【备份数据】
```shell
sudo docker container exec 容器名 sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql
```

---

[首 页](https://patrickj-fd.github.io)
