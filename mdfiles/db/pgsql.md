[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 安装
## 使用Docker安装
[使用Docker安装](../docker/apps/postgresql)

## 在主机上源码编译安装
```shell
# yum install -y readline-devel zlib-devel flex bison
apt install -y libreadline-dev zlib1g-dev flex bison
# ubuntu docker: apt install -y gcc automake autoconf libtool make

PGSQL_HOME="指定目录"
PGSQL_PGDATA="指定目录"
PGSQL_LOGS="指定目录"

./configure --prefix=$PGSQL_HOME
make -j
make install

# 安装file_fdw
cd postgresql-源码解压目录/contrib/file_fdw
make -j
make install

# 创建 postgres 用户
useradd --home-dir=$PGSQL_HOME --shell=/bin/bash postgres
chown -R postgres.postgres $PGSQL_HOME
chown -R postgres.postgres $PGSQL_PGDATA
chown -R postgres.postgres $PGSQL_LOGS

# 初始化数据库
su - postgres
# 确认环境变量中的LANG是否正确
export LANG=en_US.utf8
export LANGUAGE=en_US.UTF-8
$PGSQL_HOME/bin/initdb -E UTF8 -D $PGSQL_PGDATA --locale=en_US.UTF-8 -U postgres

sed -i "s/^#listen_addresses.*/listen_addresses='*'/"  $PGSQL_PGDATA/postgresql.conf
sed -i "s/^#port.*/port=$PGSQL_PORT}/"  $PGSQL_PGDATA/postgresql.conf
sed -i "s/^max_connections.*/max_connections=20/"  $PGSQL_PGDATA/postgresql.conf
sed -i "s/^shared_buffers.*/shared_buffers=32M/"  $PGSQL_PGDATA/postgresql.conf
sed -i "s%^log_directory.*%log_directory = '$PGSQL_LOGS'%"  $PGSQL_PGDATA/postgresql.conf
# 配置客户端访问限制：trust为无密码信任登录，只需输入ip和port即可登录；md5需要用户验证登录；ident为映射系统账户到pgsql访问账户。 
echo "host all all 0.0.0.0/0  trust"  >> $PGSQL_PGDATA/pg_hba.conf

netstat -ntlp|grep :$PGSQL_PORT
```

# 启动服务、建库和用户
```shell
# 启动服务
$PGSQL_HOME/bin/pg_ctl -D $PGSQL_PGDATA -l $PGSQL_LOGS/dbserver.log start
# 或者，在root用户下启动：
su - postgres -c "$PGSQL_HOME/bin/pg_ctl -D $PGSQL_PGDATA -l $PGSQL_LOGS/dbserver.log start"

# 创建数据库和用户
echo "create user $PGSQL_DBUSER with superuser password '$PGSQL_DBPAWD';" > /tmp/PGInitFile
echo "CREATE DATABASE $PGSQL_DBNAME OWNER=$PGSQL_DBUSER;" >> /tmp/PGInitFile
$PGSQL_HOME/bin/psql -h 127.0.0.1 -d postgres -p $PGSQL_PORT -f /tmp/PGInitFile
# 或者，在root用户下执行：
su - postgres -c "$PGSQL_HOME/bin/psql -U postgres"
```

# 常用操作
## 修改密码
```
su - postgres -c "$PGSQL_HOME/bin/psql -U postgres"

postgres=# Alter USER postgres WITH PASSWORD '密码';
ALTER ROLE        //出现这个才算成功
或者
postgres=# \password postgres
```

## 重新加载配置文件
```
pg_ctl reload -D PGDATA
或者psql登录后
select pg_reload_conf()
```

---

[首 页](https://patrickj-fd.github.io/index)
