[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建

```shell
# 1. 拉取镜像
sudo docker pull registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g


# 2. 启动一个临时容器，获取初始化数据
sudo docker container run -d -p 1521:1521 --name TempOraCar \
     registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g
docker container ls -a --filter name=TempOraCar
# 建立本地持久化数据存储根目录
LocalVolumeRoot=/data2/DockerUserWorkEnv/UserWorkfolder/oracle/11g_GBK
[ -d $LocalVolumeRoot ] && echo "LocalVolumeRoot is exist, and do nothing." || mkdir -p $LocalVolumeRoot
# 从容器中把oracle数据文件拷贝下来
sudo docker cp TempOraCar:/home/oracle/app/oracle/oradata/helowin $LocalVolumeRoot && ls -l $LocalVolumeRoot
# 本地数据目录赋权限： 500 是容器里的oarcle用户id和组id
sudo chown -R 500.500 $LocalVolumeRoot/helowin; ls -l $LocalVolumeRoot
# 获取完初始数据后即可删除这个临时容器
sudo docker container rm -f TempOraCar
docker container ls -a | grep TempOraCar


# 3. 创建正式容器
CAR_NAME=myOracle11g
sudo docker container run -d -p 1521:1521 --name $CAR_NAME \
     -v $LocalVolumeRoot/helowin:/home/oracle/app/oracle/oradata/helowin \
     registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g
docker container ls -a | grep $CAR_NAME


# 4. 初始化数据库
# 进入容器，配置oracle环境（配置环境变量和修改账户密码）
sudo docker exec -it $CAR_NAME bash

source /home/oracle/.bash_profile

# su # pwd: helowin
# echo "export ORACLE_HOME=/home/oracle/app/oracle/product/11.2.0/dbhome_2" >> /etc/profile
# echo "export ORACLE_SID=helowin" >> /etc/profile
# echo "export PATH=\$ORACLE_HOME/bin:\$PATH" >> /etc/profile
# source /etc/profile
# echo $ORACLE_HOME  # check
# ln -s $ORACLE_HOME/bin/sqlplus /usr/bin

# 删除新生成的版本控制文件，将数据卷中的版本控制文件复制为新生成的版本控制文件
rm -rf $ORACLE_BASE/flash_recovery_area/helowin/control02.ctl
cp $ORACLE_BASE/oradata/helowin/control01.ctl $ORACLE_BASE/flash_recovery_area/helowin/control02.ctl

# su oracle
sqlplus /nolog
# 在sqlplus终端中执行：
connect /as sysdba
# 关闭库。会报错 ORA-01507: database not mounted。不用管他
shutdown immediate
startup

# 修改 sys 和 system 的密码并且修改密码的有效时间为无限
alter user system identified by system;
alter user sys identified by sys;
alter profile default limit password_life_time unlimited;
# 创建一个 test 用户，密码 oracle
create user test identified by oracle;
select username,user_id, ACCOUNT_STATUS from dba_users t where t.username = 'TEST';
# 给用户授予连接和数据权限
grant connect, resource to test;
# 退出 sqlplus
quit
```

# 查看状态
```shell
lsnrctl status
```

应该看到如下信息：  
```txt
Service "helowin" has 1 instance(s).
  Instance "helowin", status READY, has 1 handler(s) for this service...
Service "helowinXDB" has 1 instance(s).
  Instance "helowin", status READY, has 1 handler(s) for this service...
The command completed successfully
```
有两个 service_name : helowin / helowinXDB 。
客户端连接时，用哪个都行。

# 参考命令

在容器外部(宿主机)执行sqlplus：
```shell
sudo docker exec -it $CAR_NAME bash -c "source /home/oracle/.bash_profile; sqlplus /nolog"
sudo docker exec -it $CAR_NAME bash -c "source /home/oracle/.bash_profile; sqlplus / as sysdba"

# sqlplus username/pwd@host/service_name
sudo docker exec -it $CAR_NAME bash -c "source /home/oracle/.bash_profile; sqlplus test/oracle"
```

加载外部表
```shell
sqlplus / as sysdba
# 给用户授权
grant create any directory to test;
quit

sqlplus test/oracle

create or replace directory SQLDR as '/home/oracle/test-DR1';

drop table user_test_gbk;
create table user_test_gbk(
  duid   VARCHAR2(5),
  name   VARCHAR2(8),
  info   VARCHAR2(20),
  cs     VARCHAR2(3)
)
organization external(
  type ORACLE_LOADER
  default directory SQLDR
  access parameters 
  (
        RECORDS DELIMITED BY NEWLINE
        CHARACTERSET ZHS16GBK
        FIELDS TERMINATED BY ","
        missing field values are null
        BADFILE 'SQLDR':'rst-badfile.dat'
        DISCARDFILE 'SQLDR':'rst-disfile.dat'
        LOGFILE 'rst-murex_gl_temp.log'
        READSIZE 1048576
  )
  location (SQLDR:'user-gbk.txt')
)
reject limit UNLIMITED;


select * from user_test_gbk;
```

```sql
create or replace directory TESTDR1 as '/home/oracle/test-DR1';
drop table user_test_gbk11;
create table user_test_gbk11(
  duid   VARCHAR2(5),
  name   VARCHAR2(8),
  info   VARCHAR2(20),
  cs     VARCHAR2(3)
)
organization external(
  type ORACLE_LOADER
  default directory TESTDR1
  access parameters 
  (
        RECORDS DELIMITED BY NEWLINE
        CHARACTERSET ZHS16GBK
        FIELDS TERMINATED BY ","
        missing field values are null
  )
  location ('user-gbk.txt')
)
reject limit UNLIMITED;
```

---

[首 页](https://patrickj-fd.github.io)
