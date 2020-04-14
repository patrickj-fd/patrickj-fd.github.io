[首 页](https://patrickj-fd.github.io/index)

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

IMAGE_NAME="hrs-postgresql"
IMAGE_TAG="11.7"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
SOURCES_LIST=$(cat /data1/docker/apps/apt-sources.list)
# ----------------- Dockerfile Start -----------------
PG_CNF_FILE="/etc/postgresql/postgresql.conf"
cat >$DFILE_NAME <<EOF
FROM postgres:11.7

ARG  PG_CNF_FILE=/etc/postgresql/postgresql.conf
ENV  TZ=Asia/Shanghai \
     LANG=en_US.utf8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
     POSTGRES_PASSWORD=HRS123321

# max_connections > ( max_wal_senders + superuser_reserved_connections )
RUN  set -ex && \
$SOURCES_LIST
     echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
     apt-get update && \
     apt-get install -yq --allow-unauthenticated --no-install-recommends locales vim wget && \
     localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/* && \
     \
     cp /usr/share/postgresql/postgresql.conf.sample $PG_CNF_FILE && \
     sed -i "s/^[[:space:]]*#[[:space:]]*listen_addresses.*/listen_addresses='*'/" $PG_CNF_FILE ; \
     sed -i "s/^[[:space:]]*listen_addresses.*/listen_addresses='*'/" $PG_CNF_FILE ; \
     \
     sed -i "s/^[[:space:]]*#[[:space:]]*max_connections.*/max_connections=20/" $PG_CNF_FILE ; \
     sed -i "s/^[[:space:]]*max_connections.*/max_connections=20/" $PG_CNF_FILE ; \
     \
     sed -i "s/^[[:space:]]*#[[:space:]]*shared_buffers.*/shared_buffers=32MB/" $PG_CNF_FILE ; \
     sed -i "s/^[[:space:]]*shared_buffers.*/shared_buffers=32MB/" $PG_CNF_FILE

EOF
# ----------------- Dockerfile End  -----------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo "================================================================"
echo "image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo "================================================================"
```
几点说明：
- "echo debconf ..." ： 这句是为了解决构建过程中提示系统服务要重启的[yes|no]选择问题
- "locales 和 localedef" ： 这是为了安装en_US.utf8，否则在initdb的时候，会报错：invalid locale settings; check LANG and LC_* environment variables
- "TZ=Asia/Shanghai" ： 为了让容器中的时间是东八区


# 启动容器
```shell
CAR_NAME="hrs-pgsql"
DATA_DIR="/tmp/pgdata"
sudo docker container run -d -p 35432:5432 --name $CAR_NAME \
     -v $DATA_DIR:/var/lib/postgresql/data \
     -e POSTGRES_PASSWORD=123456 \
     hrs-postgresql:11.7 -c 'config_file=/etc/postgresql/postgresql.conf'
# 或者，启动时直接设置配置参数
     hrs-postgresql:11.7 -c 'shared_buffers=256MB' -c 'max_connections=200'
```

# 用容器执行psql执行
```shell
sudo docker container run --rm -it hrs-postgresql:11.7 psql -U postgres -h 容器的IP
# 执行以上命令进入psql交互环境，看看配置是否生效了
show max_connections;
show shared_buffers;

# 修改 pg_hba.conf ，可以避免每次连接都输入密码
echo "host all all 192.168.8.169/32  trust" >> pg_hba.conf
```

---

[首 页](https://patrickj-fd.github.io)
