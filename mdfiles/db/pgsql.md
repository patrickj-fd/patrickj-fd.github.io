[首 页](https://patrickj-fd.github.io/index)

---

```
# yum install -y readline-devel zlib-devel flex bison
apt install -y libreadline-dev zlib1g-dev flex bison

PGSQL_HOME=/opt/postgresql-11.7
./configure --prefix=$PGSQL_HOME
make -j
make install

# 安装file_fdw
cd postgresql-源码解压目录/contrib/file_fdw
make -j
make install


# 初始化数据库

$PGSQL_HOME/bin/initdb -E UTF8 -D $PGSQL_PGDATA

sed -i "s/^#listen_addresses.*/listen_addresses='*'/"  $PGSQL_PGDATA/postgresql.conf
sed -i "s/^#port.*/port=$PGSQL_PORT}/"  $PGSQL_PGDATA/postgresql.conf
sed -i "s/^max_connections.*/max_connections=20/"  $PGSQL_PGDATA/postgresql.conf
sed -i "s/^shared_buffers.*/shared_buffers=32M/"  $PGSQL_PGDATA/postgresql.conf
echo "host all all 0.0.0.0/0  trust"  >> $PGSQL_PGDATA/pg_hba.conf

# 启动服务
$PGSQL_HOME/bin/pg_ctl -D $PGSQL_PGDATA -l $PGSQL_LOGS/dbserver.log start

# 创建数据库和用户
echo "create user $PGSQL_DBUSER with superuser password '$PGSQL_DBPAWD';" > /tmp/PGInitFile
echo "CREATE DATABASE $PGSQL_DBNAME OWNER=$PGSQL_DBUSER;" >> /tmp/PGInitFile
$PGSQL_HOME/bin/psql -h 127.0.0.1 -d postgres -p $PGSQL_PORT -f /tmp/PGInitFile
```

---

[首 页](https://patrickj-fd.github.io/index)
